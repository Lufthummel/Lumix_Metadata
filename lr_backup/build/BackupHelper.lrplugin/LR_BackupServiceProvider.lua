--[[----------------------------------------------------------------------------

LR_BackupExportServiceProvider.lua
Backup Jpegs in High Quality, Thumbnails and related Raws/XMP to selected folder

--------------------------------------------------------------------------------
(c) Dr. Holger Kremmin
licensed under the "WhatTheFuck" License. Unless you use this software to kill any
animal or human being do what you want with this software

------------------------------------------------------------------------------]]

-- FtpUpload plug-in
require "LR_BackupExportDialogSections"
require "LR_BackupTask"


--============================================================================--

return {
	
	hideSections = { 'exportLocation', 'video' },

	allowFileFormats = {'JPEG', 'TIFF' }, --nil, -- nil equates to all available formats
	
	allowColorSpaces = nil, -- nil equates to all color spaces

	exportPresetFields = {
		{ key = 'thumbnails', default = true },
		{ key = 'path', default = nil },
		-- { key = "ftpPreset", default = nil },
		-- { key = 'exportPath', default = 'abc' },
	},

	startDialog = LR_BackupExportDialogSections.startDialog,
	sectionsForBottomOfDialog = LR_BackupExportDialogSections.sectionsForBottomOfDialog,
	
	processRenderedPhotos = LR_BackupTask.processRenderedPhotos,
	
}
