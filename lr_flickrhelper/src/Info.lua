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

	LrToolkitIdentifier = 'com.minaxsoft.flickrhelper',
	LrLibraryMenuItems = {
		title = LOC "$$$/LumixMetadata/MenuEntry=Update Flickr Metadata", -- The display text for the menu item
		file = "UpdateFlickrMetadata.lua", -- The script that runs when the item is selected
		enabledWhen = "photosSelected",
	},
	LrPluginName = "Flickr Helper",

	-- Add the Metadata Tagset File
	LrMetadataTagsetFactory = {
		'FlickrMetadataTagset.lua'
	},

	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	LrInitPlugin = 'PluginInit.lua',

	LrMetadataProvider = 'FlickrMetadataDefinitionFile.lua',

	VERSION = { major=0, minor=9, revision=2, build=94}

}
