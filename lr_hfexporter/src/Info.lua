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

return {
    LrSdkVersion = 6,
    LrToolkitIdentifier = "com.minaxsoft.hf",
    LrPluginName = LOC("$$$/PluginInfo/Name=HF Stack Export"),
    LrPluginInfoUrl = "https://www.minaxsoft.com",
    LrInitPlugin = 'PluginInit.lua',
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    LrExportMenuItems = {title = "Stack in Helicon Focus...", file = "Export2HFMenuAction.lua", enabledWhen = "photosSelected"},
    LrExportServiceProvider = {title = "HF Exporter", file = "HFExportServiceProvider.lua", builtInPresetsDir = "presets"},
    VERSION = { major=0, minor=1, revision=1, build=63}
}

