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
			readOnly = true,
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
			readOnly = true,
			version = 1,

		},

        {
            id = 'fOV',
            title = LOC "$$$/LumixMetadata/AFPointPosition=FOV",
            dataType = 'string',
            searchable = true,
            browsable = true,
            version = 1,

        },

        {
            id = 'hyperFocal',
            title = LOC "$$$/LumixMetadata/AFPointPosition=Hyperfocal Distance",
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
			id = 'burstmode',
			title = LOC "$$$/LumixMetadata/BurstMode=Burst Mode",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'macromode',
			title = LOC "$$$/LumixMetadata/MacroMode=Macro Mode",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'sequencenumber',
			title = LOC "$$$/LumixMetadata/Sequence=Sequence#",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 2,

		},


		{
			id = 'shutterType',
			title = LOC "$$$/LumixMetadata/ShutterType=Shutter Type",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'accelerometerx',
			title = LOC "$$$/LumixMetadata/AccelerometerX=Accel. X",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'accelerometery',
			title = LOC "$$$/LumixMetadata/AccelerometerY=Accel. Y",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'accelerometerz',
			title = LOC "$$$/LumixMetadata/AccelerometerY=Accel. Z",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'cameraorientation',
			title = LOC "$$$/LumixMetadata/CameraOrientation=Cam Orientation",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'rollangle',
			title = LOC "$$$/LumixMetadata/RollAngle=Roll Angle",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'pitchangle',
			title = LOC "$$$/LumixMetadata/PitchAngle=Pitch Angle",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'longExposurenoisereduction',
			title = LOC "$$$/LumixMetadata/LongExposureNoiseReduction=LE Noise Reduction",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'flashbias',
			title = LOC "$$$/LumixMetadata/FlashBias=Flash Bias",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'flashcurtain',
			title = LOC "$$$/LumixMetadata/FlashCurtain=Flash Curtain",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'flashfired',
			title = LOC "$$$/LumixMetadata/FlashFired=Flash Fired",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'imagestabilization',
			title = LOC "$$$/LumixMetadata/ImageStabilization=Stabilization",
			dataType = 'string',
			searchable = true,
			browsable = true,
			version = 1,

		},

		{
			id = 'timesincepoweron',
			title = LOC "$$$/LumixMetadata/TimeSincePowerOn=Time since PO",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 1,

		},

		{
			id = 'timelapsenumber',
			title = LOC "$$$/LumixMetadata/TimeLapse=TimeLapse#",
			dataType = 'string',
			searchable = false,
			browsable = false,
			version = 2,

		},

		{
			id = 'filesize',
			title = LOC "$$$/LumixMetadata/Filesize=Filesize#",
			dataType = 'string',
			readOnly = true,
			searchable = true,
			browsable = true,
			version = 1,

		},

	},
	
	schemaVersion = 4,

}
