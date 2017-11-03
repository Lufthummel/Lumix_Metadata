--[[----------------------------------------------------------------------------

LumixMetadataTagset.lua
LumixMetadata.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2016 Dr. Holger Kremmin
 All Rights Reserved.

NOTICE:

This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

It can be used for any purpose so long as the copyright notice above,
the web-page links above, and all Author and Version informations are
maintained.

Hope it is useful.

------------------------------------------------------------------------------]]
-- This tagset includes also custom Lumix Metadata information

return {

    title = LOC "$$$/CustomMetadata/Tagset/Title=Lumix Metadata",
    id = "LumixMetadataTagset",

    items = {
        "com.adobe.filename",
        "com.adobe.originalFilename.ifDiffers",
        "com.adobe.copyname",
        "com.adobe.folder",
        "com.adobe.filesize",
        "com.adobe.fileFormat",
        "com.adobe.metadataStatus",
        "com.adobe.metadataDate",


        "com.adobe.separator",

        "com.adobe.title",
        {	"com.adobe.caption", height_in_lines = 3 },

        "com.adobe.separator",
        {
            formatter = "com.adobe.label",
            label = LOC "$$$/CustomMetadata/Fields/ExifLabel=LR EXIF",
        },

        "com.adobe.imageFileDimensions",		-- dimensions
        "com.adobe.imageCroppedDimensions",

        "com.adobe.exposure",					-- exposure factors
        "com.adobe.brightnessValue",
        "com.adobe.exposureBiasValue",
        "com.adobe.flash",
        "com.adobe.exposureProgram",
        "com.adobe.meteringMode",
        "com.adobe.ISOSpeedRating",

        "com.adobe.focalLength",				-- lens info
        "com.adobe.focalLength35mm",
        "com.adobe.lens",
        "com.adobe.subjectDistance",

        "com.adobe.dateTimeOriginal",
        "com.adobe.dateTimeDigitized",
        "com.adobe.dateTime",

        "com.adobe.make",						-- camera
        "com.adobe.model",
        "com.adobe.serialNumber",


        "com.adobe.separator",                  -- lumix
        {
            formatter = "com.adobe.label",
            label = LOC "$$$/CustomMetadata/Fields/LumixInfoLabel=Lumix EXIF",
        },

        "de.minaxsoft.lumixmetadata.*",
    }


}


