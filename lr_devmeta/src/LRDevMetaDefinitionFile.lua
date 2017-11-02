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
			id = 'lrdevmetaId',
		},

		{
			id = 'processVersion',
			title = LOC "$$$/LRDevMeta/ProcessVersion=Process Version",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'luminance',
			title = LOC "$$$/LRDevMeta/Luminance=Luminance",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'hue',
			title = LOC "$$$/LRDevMeta/HUE=HUE",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'saturation',
			title = LOC "$$$/LRDevMeta/Saturation=Saturation",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'enabled',
			title = LOC "$$$/LRDevMeta/Enabled=Enabled Settings",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'other',
			title = LOC "$$$/LRDevMeta/Other=Uncategorized",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'twentytwelve',
			title = LOC "$$$/LRDevMeta/TwentyTwelve=2012",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'parametric',
			title = LOC "$$$/LRDevMeta/Parametric=Parametric",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'curve',
			title = LOC "$$$/LRDevMeta/ToneCurve=Tone Curve",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'crop',
			title = LOC "$$$/LRDevMeta/Crop=Crop",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'perspective',
			title = LOC "$$$/LRDevMeta/Perspective=Perspective",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'redeye',
			title = LOC "$$$/LRDevMeta/RedEye=Red Eye",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'retouch',
			title = LOC "$$$/LRDevMeta/Retouch=Retouch",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

	},
	
	schemaVersion = 1,

}
