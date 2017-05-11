--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 15.04.16
-- Time: 19:36
-- To change this template use File | Settings | File Templates.
--
local LrPrefs = import "LrPrefs"
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"

local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)

if (pluginPrefs.exiftool == nil) then

    _G.EXIFTOOLPATH = '/usr/local/bin/exiftool'

else
    _G.EXIFTOOLPATH = pluginPrefs.exiftool
end

--[[
if (pluginPrefs.ffmpeg == nil) then

    _G.FFMPEGPATH = '/usr/local/bin/ffmpeg'

else
    _G.FFMPEGPATH = pluginPrefs.ffmpeg
end
]]

if (pluginPrefs.lrpath == nil) then

    _G.LRPATH = '/tmp/'

else
    _G.LRPATH = pluginPrefs.lrpath
end


if (pluginPrefs.videopath == nil) then

    _G.VIDEOPATH = '/tmp/'

else
_G.VIDEOPATH = pluginPrefs.videopath
end

if (pluginPrefs.format == nil) then

    _G.FORMAT = 'jpeg'

else
    _G.FORMAT = pluginPrefs.format
end



_G.SEP = '/'



if WIN_ENV == true then
    _G.FFMPEGPATH = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), "ffmpeg.exe" ) .. '"'
    _G.EXIFTOOLPATH = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), "exiftool.exe" ) .. '"'
    myLogger:trace( " Windows Environment" .. _G.FFMPEGPATH .. " + " ..  _G.EXIFTOOLPATH)
else
    _G.FFMPEGPATH = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), "ffmpeg" ) .. '"'
    _G.EXIFTOOLPATH = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), "/bin/exiftool" ) .. '"'
    myLogger:trace( " On a Mac, ffmpeg =  " .. _G.FFMPEGPATH .. " + " ..  _G.EXIFTOOLPATH)

end