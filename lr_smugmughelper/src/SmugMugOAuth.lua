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
local LrHttp = import 'LrHttp'
local LrMD5 = import 'LrMD5'
local LrStringUtils = import "LrStringUtils"
local LrView = import 'LrView'
local LrTasks = import 'LrTasks'
local LrXml = import 'LrXml'

local prefs = import 'LrPrefs'.prefsForPlugin()

local bind = LrView.bind
local share = LrView.share

local logger = import 'LrLogger'( 'libraryLogger' )
logger:enable('logfile')

--move the OAuth stuff to Global --

local REQUEST_TOKEN_URL ="https://api.smugmug.com/services/oauth/1.0a/getRequestToken"
local USER_AUTH_URL = "https://api.smugmug.com/services/oauth/1.0a/authorize"
local ACCESS_TOKEN_URL = "https://api.smugmug.com/services/oauth/1.0a/getAccessToken"
local CALLBACK_URL = "lightroom://com.minaxsoft.smugmughelper"


local SALT = "0815"

require 'sha1.lua'
require 'keys.lua'

SmugMugOAuth = {}

--------------------------------------------------------------------------------

local appearsAlive

--------------------------------------------------------------------------------

local function formatError( nativeErrorCode )
    return LOC "$$$/SmugMugHelper/Error/NetworkFailure=Could not connect SmugMug. Please check your Internet connection."
end

--------------------------------------------------------------------------------

local function trim( s )
    return string.gsub( s, "^%s*(.-)%s*$", "%1" )
end

--------------------------------------------------------------------------------

-- support functions --

-- Cocaoa time of 0 is unix time 978307200
local COCOA_TIMESHIFT = 978307200

--[[ Some Handy Helper Functions
local function oauth_encode( value )
    return tostring( string.gsub( value, "[^-._~a-zA-Z0-9]",
        function( c )
            return string.format( "%%%02x", string.byte( c ) ):upper()
        end ) )
end
]]--
local function oauth_encode(val)
    return tostring(val:gsub('[^-._~a-zA-Z0-9]', function(letter)
        return string.format("%%%02x", letter:byte()):upper()
    end))
    -- The wrapping tostring() above is to ensure that only one item is returned (it's easy to
    -- forget that gsub() returns multiple items
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
        logger:info("value = " .. value)

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
        logger:info("querystring = " .. query_string)
        logger:info("header = " .. header)
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
function SmugMugOAuth.refreshToken(propertyTable)
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
function SmugMugOAuth.login(context)
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

    SmugMugOAuth.URLCallback = function( code )
        logger:info("URLCallback2", code)

        properties.verifier = code
        LrDialogs.stopModalWithResult(contents, "ok")
    end

    local action = LrDialogs.presentModalDialog( {
        title = "Enter verification token",
        contents = contents,
        actionVerb = "Authorize"
    } )

    SmugMugOAuth.URLCallback = nil

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

function SmugMugOAuth.getUserId(propertyTable)
    logger:trace("getUserId", prefs.userId)
    if prefs.userId then
        return prefs.userId
    end

    SmugMugOAuth.listAlbums(propertyTable)
    return prefs.userId
end



function SmugMugOAuth.authorize()

    logger:info("starting oauth process")


    -- required arguments
    local http_method = "GET"
    local consumer_key = _G.SMUGMUGCONSUMERKEY
    local oauth_args = {
        oauth_callback = CALLBACK_URL,
        oauth_consumer_key = consumer_key,
        oauth_nonce = generate_nonce(),
        oauth_version= "1.0",
        oauth_signature_method = "PLAINTEXT", --"HMAC-SHA1",
        oauth_timestamp = unix_timestamp(),
    }

    -- encode all keys and values
    local keys_and_values = { }

    for key, val in pairs(oauth_args) do
        table.insert(keys_and_values,  {
            key = oauth_encode(key),
            val = oauth_encode(val)
        })
    end

    -- Sort by key first, then value
    table.sort(keys_and_values, function(a,b)
        if a.key < b.key then
            return true
        elseif a.key > b.key then
            return false
        else
            return a.val < b.val
        end
    end)

    -- Now combine key and value into key=value
    local key_value_pairs = { }
    for _, rec in pairs(keys_and_values) do
        table.insert(key_value_pairs, rec.key .. "=" .. rec.val)
    end

    -- query string for signing,

    local query_string_except_signature = table.concat(key_value_pairs, "&")
    local SignatureBaseString = http_method .. '&' .. oauth_encode(REQUEST_TOKEN_URL) .. '&' .. oauth_encode(query_string_except_signature)
    local key = oauth_encode(_G.SMUGMUGSECRETKEY) -- .. '&' .. oauth_encode(token_secret)

    -- Now have our text and key for HMAC-SHA1 signing
    local hmac_binary = hmac_sha1_binary(key, SignatureBaseString)
    -- Base64 encode it
    local hmac_b64 = LrStringUtils.encodeBase64(hmac_binary)
    -- Now append the signature to end up with the final query string

    local plaintext_sig = oauth_encode(_G.SMUGMUGSECRETKEY .. '&')
    local query_string = REQUEST_TOKEN_URL .. "?" .. query_string_except_signature .. '&oauth_signature=' .. plaintext_sig --oauth_encode(hmac_b64)

    logger:info("request for signing  = " .. SignatureBaseString)

    LrDialogs.message("Start Authorization process?" .. query_string)

    -- request token url returns these two tokens
    local oauth_token = ""
    local oauth_token_secret = ""

    LrTasks.startAsyncTask( function()
        local result, headers = LrHttp.get( query_string    )
        logger:info("request url response " .. result )

        if not result or not headers.status then
            LrErrors.throwUserError( "Could not connect to SmugMug. Please make sure you are connected to the internet and try again." )
        end

        oauth_token = result:match( "oauth_token=([^&]+)" )
        oauth_token_secret = result:match( "oauth_token_secret=([^&]+)" )

        LrDialogs.message("tk = " .. oauth_token .. " tks " .. oauth_token_secret)

    end )




    --[[
           1. Obtain a request token
           2. Redirect the user to the authorization URL
           3. The user logs in to SmugMug
           4. The user is presented with a request to authorize your app
           5. If the user accepts, they will be redirected back to your app, with a verification code embedded in the request
           6. Use the verification code to obtain an access token
     ]]

end




