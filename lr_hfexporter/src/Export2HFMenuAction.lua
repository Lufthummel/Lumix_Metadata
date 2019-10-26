--[[----------------------------------------------------------------------------

Info.lua
HFExporter.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2019 Dr. Holger Kremmin
 All Rights Reserved.

NOTICE:

This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

It can be used for any purpose so long as the copyright notice above,
the web-page links above, and all Author and Version informations are
maintained.

Hope it is useful.

------------------------------------------------------------------------------]]


local LrApplication = import("LrApplication")
local LrErrors = import("LrErrors")
local LrTasks = import("LrTasks")
local LrExportSession = import("LrExportSession")
local LrLogger = import("LrLogger")
local logger = LrLogger("libraryLogger")
logger:enable("logfile")


LrTasks.startAsyncTask(function()
  -- function num : 0_0 , upvalues : logger, LrApplication, LrExportSession
  logger:trace("start exporting to Helicon ...")
  local activeCatalog = (LrApplication.activeCatalog)()
  local filmstrip = activeCatalog.targetPhotos
  local exportSession = LrExportSession({
    exportSettings = {
      LR_exportServiceProvider = "com.minaxsoft.hf",
      LR_exportServiceProviderTitle = "Stack in Helicon Focus",
      LR_format = "TIFF",
      LR_tiff_compressionMethod = "compressionMethod_None",
      LR_export_bitDepth = 16, LR_export_colorSpace = "AdobeRGB",
      LR_minimizeEmbeddedMetadata = false,
      LR_size_resolution = 300,
      LR_metadata_keywordOptions = "lightroomHierarchical",
      LR_minimizeEmbeddedMetadata = false,
      LR_removeLocationMetadata = false,
      LR_export_destinationPathPrefix = _G.TMPPATH,
      LR_export_destinationType = "specificFolder",
      LR_export_useSubfolder = false,
      LR_collisionHandling = "overwrite"
    },

  photosToExport = filmstrip})

  exportSession:doExportOnCurrentTask()
end)

