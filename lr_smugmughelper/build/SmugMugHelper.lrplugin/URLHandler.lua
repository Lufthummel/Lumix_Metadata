local LrDialogs = import "LrDialogs"

require "SmugMugOAuth"
local logger = import 'LrLogger'( 'FlickrAPI' )
-- logger:enable('logfile')


return {
    URLHandler = function ( url )
        logger:info("URLCallback", url)

        LrDialogs.message("URLCallback = " .. url)

        --if FlickrOAuth.URLCallback then
        --    FlickrOAuth.URLCallback( url:match( "code=([^&]+)" ) )
        --end
    end
}