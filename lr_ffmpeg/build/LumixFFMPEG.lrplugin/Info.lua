--[[----------------------------------------------------------------------------

Info.lua
LumixMetadata.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2015 Dr. Holger Kremmin
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

	LrSdkVersion = 6.0,

	LrToolkitIdentifier = 'de.minaxsoft.lumixffmpeg',
	LrExportMenuItems = {
		title = LOC "$$$/LumixFFMPEG/MenuEntry=Extract Frames from Video", -- The display text for the menu item
		file = "ImportVideo.lua", -- The script that runs when the item is selected
		enabledWhen = "photosAvailable",
	},
	LrPluginName = "Lumix FFMPEG",



	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	LrInitPlugin = 'PluginInit.lua',


	VERSION = { major=0, minor=1, revision=1, build=132}

}
