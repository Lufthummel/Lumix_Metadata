--[[----------------------------------------------------------------------------

Info.lua
Backup Jpegs in High Quality, Thumbnails and related Raws/XMP to selected folder

--------------------------------------------------------------------------------
(c) Dr. Holger Kremmin
licensed under the "WhatTheFuck" License. Unless you use this software to kill any
animal or human being do what you want with this software

------------------------------------------------------------------------------]]

return {

	LrSdkVersion = 6.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.minaxsoft.lrbackup',

	LrPluginName = LOC "$$$/FTPUpload/PluginName=Backup Helper",
	
	LrExportServiceProvider = {
		title = "Backup Helper",
		file = 'LR_BackupServiceProvider.lua',
	},

	VERSION = { major=0, minor=1, revision=0, build=83}

}
