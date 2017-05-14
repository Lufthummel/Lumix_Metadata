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


if (pluginPrefs.converter == nil) then

_G.CONVERTERPATH = '/usr/local/bin/gm'

else
_G.CONVERTERPATH = pluginPrefs.converter
end


if (pluginPrefs.videopath == nil) then

    _G.VIDEOPATH = '/usr/local/bin/gm'

else
    _G.VIDEOPATH = pluginPrefs.videopath
end

if (pluginPrefs.filepath == nil) then

    _G.FILEPATH = '/tmp'

else
    _G.FILEPATH = pluginPrefs.filepath
end

myLogger:trace( " --> " .. _G.VIDEOPATH)

if (pluginPrefs.lrpath == nil) then

_G.LRPATH = '/usr/local/bin/gm'

else
_G.LRPATH = pluginPrefs.lrpath
end

if (pluginPrefs.fileoutpath == nil) then

    _G.FILEOUTPATH = '/tmp'

else
    _G.FILEOUTPATH = pluginPrefs.fileoutpath
end



if (pluginPrefs.format == nil) then

    _G.FORMAT = 'jpeg'

else
    _G.FORMAT = pluginPrefs.format
end

if (pluginPrefs.hq == nil) then

    _G.HQ = true

else
    _G.HQ = pluginPrefs.hq
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