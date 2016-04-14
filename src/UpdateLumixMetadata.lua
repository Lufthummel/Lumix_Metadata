--
-- Created by IntelliJ IDEA.
-- User: imac
-- Date: 06.09.15
-- Time: 19:42
-- To change this template use File | Settings | File Templates.
--

require ('Helper.lua')
local LrPathUtils = import 'LrPathUtils'
local JSON = assert(loadfile (LrPathUtils.child(_PLUGIN.path, "JSON.lua")))() -- one-time load of the routines

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "print" ) -- or "logfile"


local updateProgress = {}

UpdateLumixMetadata = {}

function UpdateLumixMetadata.showUpdateDialog()
    -- body of function
    -- LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )

    if (LrDialogs.confirm("Update Lumix Metadata","Do you want to update Metadata?","Sure","Cancel") == "ok")
    then

    -- enable progress bar

        updateProgress = LrProgressScope({
         title = "Update Lumix Metadata",
        })
        updateProgress:setCancelable(false)

        UpdateLumixMetadata.getPhotos()
    end
end


function UpdateLumixMetadata.getPhotos()
    local catalog = LrApplication.activeCatalog()
    local path = ''
    local fname = ''
    local tmpmeta = ''
    local t = 0

    myLogger:trace( "-> getPhotos")
    LrTasks.startAsyncTask(function ()
        local photos = catalog:getMultipleSelectedOrAllPhotos()
        local totalphotos = #photos


        updateProgress:setPortionComplete(t, totalphotos)

        myLogger:trace( "-> getPhotos:startIterating, # " .. totalphotos)

        for p,photo in ipairs(photos) do
            t = t +1
            path = photo:getRawMetadata("path")
            fname = photo:getFormattedMetadata("fileName")

            -- myLogger:trace( "-> "..  path .. " + " .. fname )
            tmpmeta = exiftool(path)

            catalog:withWriteAccessDo( "UpdateMetada", function( context )
                UpdateLumixMetadata.setMetadata(tmpmeta, photo)
                myLogger:trace( "-> updated")
            end)
            myLogger:trace( "updated" .. t)
            updateProgress:setPortionComplete(t, totalphotos)
        end
    end)

    updateProgress:done()
end

function JSON:onDecodeError(message, text, location, etc)
                LrErrors.throwUserError("Internal Error: invalid JSON data" .. message .. text)
end

function UpdateLumixMetadata.setMetadata(m,p)

    myLogger:trace( "-> setMetadata")
    local photo = p
    m =m:gsub("%["," ")
    m =m:gsub("%]"," ")
    myLogger:trace("-> Metadata " .. m)

    local meta = JSON:decode(m)
    if (meta ~= nil ) then
            -- myLogger:trace("-> Metadata Lookup " .. meta["ShutterType"])
            if (meta["ShutterType"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"shutterType",meta["ShutterType"]) end
            if (meta["FirmwareVersion"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"firmwareVersion",tostring(meta["FirmwareVersion"])) end
            if (meta["InternalSerialNumber"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"internalSerialNumber",tostring(meta["InternalSerialNumber"])) end
            if (meta["LensFirmwareVersion"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"lensFirmwareVersion",tostring(meta["LensFirmwareVersion"])) end
            if (meta["LensSerialNumber"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"lensSerialNumber",tostring(meta["LensSerialNumber"])) end
            if (meta["AFPointPosition"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"aFPointPosition",tostring(meta["AFPointPosition"])) end
            if (meta["FocusMode"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"focusMode",tostring(meta["FocusMode"])) end
            if (meta["AFAreaMode"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"aFAreaMode",tostring(meta["AFAreaMode"])) end
            if (meta["BurstSpeed"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"burstSpeed","Burst -> ".. tostring(meta["BurstSpeed"])) end
        end
end

UpdateLumixMetadata.showUpdateDialog()