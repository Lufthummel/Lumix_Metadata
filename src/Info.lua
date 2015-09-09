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

	LrToolkitIdentifier = 'de.minaxsoft.lumixmetadata',
	LrLibraryMenuItems = {
		title = LOC "$$$/LumixMetadata/MenuEntry=Update Lumix Metadata", -- The display text for the menu item
		file = "UpdateLumixMetadata.lua", -- The script that runs when the item is selected
		enabledWhen = "photosSelected",
	},
	LrPluginName = "Lumix Metadata",
	


	LrMetadataProvider = 'LumixMetadataDefinitionFile.lua',

	VERSION = { major=0, minor=1, revision=0, build=85}

}
