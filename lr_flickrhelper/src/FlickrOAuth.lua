--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 04.06.17
-- Time: 18:23
-- This script handles teh OAuth dance...
--

-- Lightroom SDK
local LrBinding = import 'LrBinding'
local LrDate = import 'LrDate'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFileUtils = import 'LrFileUtils'
local LrFunctionContext = import 'LrFunctionContext'
local LrHttp = import 'LrHttp'
local LrMD5 = import 'LrMD5'
local LrPathUtils = import 'LrPathUtils'
local LrStringUtils = import "LrStringUtils"
local LrView = import 'LrView'
local LrXml = import 'LrXml'

local prefs = import 'LrPrefs'.prefsForPlugin()

local bind = LrView.bind
local share = LrView.share

local logger = import 'LrLogger'( 'FlickrOAuth' )
-- logger:enable('logfile')

--move the OAuth stuff to Global --

local ACCESS_TOKEN_URL = "https://www.googleapis.com/oauth2/v4/token"

local CONSUMER_KEY = ""
local CONSUMER_SECRET = ""
local SALT = ""

require "sha1"

FlickrOAuth = {}

--------------------------------------------------------------------------------

local appearsAlive

--------------------------------------------------------------------------------

local function formatError( nativeErrorCode )
    return LOC "$$$/FlickrHelper/Error/NetworkFailure=Could not connect Flickr. Please check your Internet connection."
end

--------------------------------------------------------------------------------

local function trim( s )
    return string.gsub( s, "^%s*(.-)%s*$", "%1" )
end

--------------------------------------------------------------------------------

--[[ Some Handy Constants ]]--

-- Cocaoa time of 0 is unix time 978307200
local COCOA_TIMESHIFT = 978307200

--[[ Some Handy Helper Functions ]]--
local function oauth_encode( value )
    return tostring( string.gsub( value, "[^-._~a-zA-Z0-9]",
        function( c )
            return string.format( "%%%02x", string.byte( c ) ):upper()
        end ) )
end

local function unix_timestamp()
    return tostring(COCOA_TIMESHIFT + math.floor(LrDate.currentTime() + 0.5))
end

local function generate_nonce()
    return LrMD5.digest( tostring(math.random())
            .. tostring(LrDate.currentTime())
            .. SALT )
end

--[[ Returns an oAuth athorization header and a query string (or post body). ]]--
local function oauth_sign( method, url, args )

    assert( method == "GET" or method == "POST" )

    --common oauth parameters
    args.oauth_consumer_key = CONSUMER_KEY
    args.oauth_timestamp = unix_timestamp()
    args.oauth_version = "1.0"
    args.oauth_nonce = generate_nonce()
    args.oauth_signature_method = "HMAC-SHA1"

    local oauth_token_secret = args.oauth_token_secret or ""
    args.oauth_token_secret = nil

    local data = ""
    local query_string = ""
    local header = ""

    local data_pattern = "%s%s=%s"
    local query_pattern = "%s%s=%s"
    local header_pattern = "OAuth %s%s=\"%s\""

    local keys = {}
    for key in pairs( args ) do
        table.insert( keys, key )
    end
    table.sort( keys )

    for _, key in ipairs( keys ) do
        local value = args[key]

        -- url encode the value if it's not an oauth parameter
        if string.find( key, "oauth" ) == 1 and key ~= "oauth_callback" then
            value = string.gsub( value, " ", "+" )
            value = oauth_encode( value )
        end

        -- oauth encode everything, non oauth parameters get encoded twice
        value = oauth_encode( value )

        -- build up the base string to sign
        data = string.format( data_pattern, data, key, value )
        data_pattern = "%s&%s=%s"

        -- build up the oauth header and query string
        if string.find( key, "oauth" ) == 1 then
            header = string.format( header_pattern, header, key, value )
            header_pattern = "%s, %s=\"%s\""
        else
            query_string = string.format( query_pattern, query_string, key, value )
            query_pattern = "%s&%s=%s"
        end
    end

    local to_sign = string.format( "%s&%s&%s", method, oauth_encode( url ), oauth_encode( data ) )
    local key = string.format( "%s&%s", oauth_encode( CONSUMER_SECRET ), oauth_encode( oauth_token_secret ) )
    local hmac_binary = hmac_sha1_binary( key, to_sign )
    local hmac_b64 = LrStringUtils.encodeBase64( hmac_binary )

    data = string.format( "%s&oauth_signature=%s", data, oauth_encode( hmac_b64 ) )
    header = string.format( "%s, oauth_signature=\"%s\"", header, oauth_encode( hmac_b64 ) )

    return query_string, { field = "Authorization", value = header }
end

--------------------------------------------------------------------------------
local function call_it( method, url, params, rid )
    local query_string, auth_header = oauth_sign( method, url, params )

    if rid then
        logger:trace( "Query " .. rid .. ": " .. method .. " " .. url .. "?" .. query_string )
    end

    if method == "POST" then
        return LrHttp.post( url, query_string,
            { auth_header,
                { field = "Content-Type", value = "application/x-www-form-urlencoded" },
                { field = "User-Agent", value = "Lightroom Flickr Helper" },
                { field = "Cookie", value = "GARBAGE" }
            }
        )
    else
        return LrHttp.get( url .. "?" .. query_string,
            { auth_header,
                { field = "User-Agent", value = "Lightroom Flickr Helper" }
            }
        )
    end
end

local function auth_header(propertyTable)
    logger:info("access_token:", propertyTable.access_token)
    return {
        { field = 'GData-Version', value = '2'},
        --{ field = 'Authorization', value = 'Bearer ' .. prefs.access_token }
        { field = 'Authorization', value = 'Bearer ' .. propertyTable.access_token }
    }
end

--------------------------------------------------------------------------------
local function findXMLNodeByName( node, name, namespace, type )
    local nodeType = string.lower( node:type() )

    if nodeType == 'element' then
        local n, ns = node:name()
        if n == name and ((not namespace) or ns == namespace) then
            if type == 'text' then
                return node:text()
            else
                return node
            end
        else
            local count = node:childCount()
            for i = 1, count do
                local result = findXMLNodeByName( node:childAtIndex( i ), name, namespace, type)
                if result then
                    return result
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
local function findXMLNodesByName( node, name, namespace, array )
    local nodeType = string.lower( node:type() )
    local ret = array and array or {}

    if nodeType == 'element' then
        local n, ns = node:name()
        if n == name and ((not namespace) or ns == namespace) then
            ret[#ret+1] = node
        else
            local count = node:childCount()
            for i = 1, count do
                findXMLNodesByName( node:childAtIndex( i ), name, namespace, ret)
            end
        end
    end
    return ret
end


--------------------------------------------------------------------------------
function FlickrOAuth.refreshToken(propertyTable)
    logger:trace('refreshToken invoked')
    -- get an access token_secret
    local args = {
        client_id = CONSUMER_KEY,
        client_secret = CONSUMER_SECRET,
        refresh_token = propertyTable.refresh_token,
        grant_type = 'refresh_token',
    }

    local response, headers = call_it( "POST", ACCESS_TOKEN_URL, args, math.random(99999) )
    logger:info("Refresh token response: ", response)
    if not response or not headers.status then
        LrErrors.throwUserError( "Could not connect to Google Photo. Please make sure you are connected to the internet and try again." )
    end
    local json = require 'json'
    local auth = json.decode(response)
    -- auth.access_token = LrStringUtils.trimWhitespace(auth.access_token)
    logger:info("Old access_token: '" .. propertyTable.access_token .. "'")
    logger:info("New access_token: '" .. auth.access_token .. "'")

    prefs.access_token = auth.access_token

    if not auth.access_token then
        LrErrors.throwUserError( "Refresh token failed." )
    end
    logger:info("Refresh token succeeded")
    return auth.access_token
end

--------------------------------------------------------------------------------
function FlickrOAuth.login(context)
    local redirectURI = 'https://stanaka.github.io/lightroom-google-photo-plugin/redirect'
    --local redirectURI = 'urn:ietf:wg:oauth:2.0:oob'
    local scope = 'https://picasaweb.google.com/data/'
    local authURL = string.format(
        'https://accounts.google.com/o/oauth2/v2/auth?scope=%s&redirect_uri=%s&response_type=code&prompt=consent&access_type=offline&client_id=%s',
        scope, redirectURI, CONSUMER_KEY)

    logger:info('openAuthUrl: ', authURL)
    LrHttp.openUrlInBrowser( authURL )

    local properties = LrBinding.makePropertyTable( context )
    local f = LrView.osFactory()
    local contents = f:column {
        bind_to_object = properties,
        spacing = f:control_spacing(),
        f:picture {
            value = _PLUGIN:resourceId( "small_flickr@2x.png" )
        },
        f:static_text {
            title = "Enter the verification token provided by the website",
            place_horizontal = 0.5,
        },
        f:edit_field {
            width = 300,
            value = bind "verifier",
            place_horizontal = 0.5,
        },
    }

    FlickrOAuth.URLCallback = function( code )
        logger:info("URLCallback2", code)

        properties.verifier = code
        LrDialogs.stopModalWithResult(contents, "ok")
    end

    local action = LrDialogs.presentModalDialog( {
        title = "Enter verification token",
        contents = contents,
        actionVerb = "Authorize"
    } )

    FlickrOAuth.URLCallback = nil

    if action == "cancel" or not properties.verifier then return nil end

    -- get an access token_secret
    local args = {
        client_id = CONSUMER_KEY,
        client_secret = CONSUMER_SECRET,
        redirect_uri = redirectURI,
        code = LrStringUtils.trimWhitespace(properties.verifier),
        grant_type = 'authorization_code',
    }

    local response, headers = call_it( "POST", ACCESS_TOKEN_URL, args, math.random(99999) )
    logger:info(response)
    if not response or not headers.status then
        LrErrors.throwUserError( "Could not connect to 500px.com. Please make sure you are connected to the internet and try again." )
    end

    local json = require 'json'
    local auth = json.decode(response)
    local access_token = auth.access_token
    -- prefs.access_token = auth.access_token
    local refresh_token = auth.refresh_token

    if not access_token or not refresh_token then
        LrErrors.throwUserError( "Login failed." )
    end
    logger:info("Login succeeded")
    return {
        access_token = access_token,
        refresh_token = refresh_token,
    }

end

function FlickrOAuth.getUserId(propertyTable)
    logger:trace("getUserId", prefs.userId)
    if prefs.userId then
        return prefs.userId
    end

    FlickrOAuth.listAlbums(propertyTable)
    return prefs.userId
end








