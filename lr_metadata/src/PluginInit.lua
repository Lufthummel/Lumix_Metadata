--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 15.04.16
-- Time: 19:36
-- To change this template use File | Settings | File Templates.
--
local LrPrefs = import "LrPrefs"

local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)

if (pluginPrefs.exiftool == nil) then

    _G.EXIFTOOLPATH = '/usr/local/bin/exiftool'

else
    _G.EXIFTOOLPATH = pluginPrefs.exiftool
end

if (pluginPrefs.tmppath == nil) then

    _G.TMPPATH = '/tmp/'

else
    _G.TMPPATH = pluginPrefs.tmppath
end