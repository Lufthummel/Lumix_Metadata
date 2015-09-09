--[[----------------------------------------------------------------------------

MyMetadataDefinitionFile.lua
MyMetadata.lrplugin

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

return {

	metadataFieldsForPhotos = {

		{
			id = 'lumixId',
		},

		{
			id = 'firmwareVersion',
			title = LOC "$$$/LumixMetadata/FirmwareVersion=Firmware Version",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'internalSerialNumber',
			title = LOC "$$$/LumixMetadata/InternalSerialNumberr=Camera Serial Number",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'lensFirmwareVersion',
			title = LOC "$$$/LumixMetadata/LensFirmwareVersion=Lens Firmware Version",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'lensSerialNumber',
			title = LOC "$$$/LumixMetadata/LensSerialNumber=Lens Serial Number",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'aFPointPosition',
			title = LOC "$$$/LumixMetadata/AFPointPosition=AF Point Position",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'focusMode',
			title = LOC "$$$/LumixMetadata/FocusMode=Focus Mode",
			dataType = 'string', -- Specifies the data type for this field.
			searchable = true,
			browsable = true,
			version = 1,
		},



		{
			id = 'aFAreaMode',
			title = LOC "$$$/LumixMetadata/AFArea=AF Area Mode",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'burstSpeed',
			title = LOC "$$$/LumixMetadata/BurstSpeed=Burst Speed",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'shutterType',
			title = LOC "$$$/LumixMetadata/ShutterType=Shutter Type",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

	},
	
	schemaVersion = 1,

}
