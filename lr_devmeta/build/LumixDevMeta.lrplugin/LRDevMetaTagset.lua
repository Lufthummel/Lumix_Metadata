--[[----------------------------------------------------------------------------

LumixMetadataTagset.lua
LumixMetadata.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2017 Dr. Holger Kremmin
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

    title = LOC "$$$/CustomMetadata/Tagset/Title=LR DevMeta",
    id = "LRDevMetaTagset",

    items = {
        "com.adobe.filename",
        "com.adobe.originalFilename.ifDiffers",
        "com.adobe.sidecars",
        "com.adobe.copyname",
        "com.adobe.folder",
        "com.adobe.filesize",
        "com.adobe.fileFormat",
        "com.adobe.metadataStatus",
        "com.adobe.metadataDate",
        "com.adobe.audioAnnotation",
        "com.adobe.separator",
        "com.minaxsoft.lrdevmeta.*",
    },

}


