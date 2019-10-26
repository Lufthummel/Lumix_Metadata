--[[----------------------------------------------------------------------------

Info.lua
HFExporter.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2019 Dr. Holger Kremmin
 All Rights Reserved.

NOTICE:

This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

It can be used for any purpose so long as the copyright notice above,
the web-page links above, and all Author and Version informations are
maintained.

Hope it is useful.

------------------------------------------------------------------------------]]

local LrPrefs = import "LrPrefs"
local LrPathUtils = import("LrPathUtils")

local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)
-- pluginPrefs.tmppath = LrPathUtils.getStandardFilePath("temp")

if (pluginPrefs.hf == nil) then

    _G.HFPATH = '/Applications/HeliconFocus.app/Contents/MacOS/HeliconFocus'

else
    _G.HFPATH = pluginPrefs.hf
end

if (pluginPrefs.tmppath == nil) then

    _G.TMPPATH = LrPathUtils.getStandardFilePath("temp")

else
    _G.TMPPATH = pluginPrefs.tmppath
end

if (pluginPrefs.collection == nil) then

    _G.COLLECTION = "Helicon"

else
    _G.COLLECTION = pluginPrefs.collection
end

if (pluginPrefs.delete == nil) then

    _G.DELETE = false

else
    _G.DELETE = pluginPrefs.delete
end


_G.OUTPUT_FILE_LIST = "hf_out.txt"
_G.INPUT_FILE_LIST = "hf_in.txt"