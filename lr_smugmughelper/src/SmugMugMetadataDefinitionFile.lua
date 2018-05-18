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
			id = 'smugId',
		},

		{
			id = 'remoteid',
			title = LOC "$$$/SmugMugHelper/SmugMugID=SmugMug photo id",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'smugurl',
			title = LOC "$$$/SmugMugHelper/SmugMugURL=SmugMug photo url",
			dataType = 'string',
			searchable = true,
			browsable = false,
			version = 1,

		},

		{
			id = 'bbshort',
			title = LOC "$$$/SmugMugHelper/BBShort=Short BB Code",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'bblong',
			title = LOC "$$$/SmugMugHelper/BBlong=Long BBCode",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'staticmedium',
			title = LOC "$$$/SmugMugHelper/BBlong=Static medium size url",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'staticlarge',
			title = LOC "$$$/SmugMugHelper/BBlong=Static large size url",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'staticoriginal',
			title = LOC "$$$/SmugMugHelper/BBlong=Static original size url",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},



	},
	
	schemaVersion = 1,

}
