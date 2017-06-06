--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 04.06.17
-- Time: 18:23
-- To change this template use File | Settings | File Templates.
--

local LrLogger = import 'LrLogger'
local LrHttp = import 'LrHttp'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"


FlickrAPI = {}


-- https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=4c05a8adc0fa073995d90cc0a0de9acc&photo_id=34082524844&format=json&nojsoncallback=1
-- returns the  the json file
function FlickrAPI.getSizes( flickrid )
    local url = string.format( 'https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%s&photo_id=%s&format=json&nojsoncallback=1', _G.FLICKRCONSUMERKEY, flickrid )
    myLogger:trace( "url = " .. url )

    local result, hdrs = LrHttp.get( url, headers )
    if result == nil then result = "-" end
    -- myLogger:trace( "result = " .. result  )

    return result

end