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
local LrErrors = import 'LrErrors'
local LrFileUtils = import 'LrFileUtils'

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
        updateProgress:setCancelable(true)

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

            if updateProgress:isCanceled() then
                updateProgress:done()
                -- myLogger:trace( "-> cancelled")
                return

            end

            t = t +1
            path = photo:getRawMetadata("path")
            fname = photo:getFormattedMetadata("fileName")

            myLogger:trace( "-> "..  path .. " + " .. fname )
            tmpmeta = exiftool(path)
            filesize = LrFileUtils.fileAttributes(path).fileSize
            filesize = filesize / (1024 * 1024)
            -- myLogger:trace( "-> filesize" .. toString(filesize))

            catalog:withWriteAccessDo( "UpdateMetada", function( context )
                UpdateLumixMetadata.setMetadata(tmpmeta, photo, filesize)
                myLogger:trace( "-> updated")
            end)
            myLogger:trace( "updated" .. t)
            updateProgress:setPortionComplete(t, totalphotos)
        end
        updateProgress:done()
    end)


end

function JSON:onDecodeError(message, text, location, etc)
                LrErrors.throwUserError("Internal Error: invalid JSON data" .. message .. location)

end


function UpdateLumixMetadata.setMetadata(m,p, filesize)

    myLogger:trace( "-> setMetadata")
    local photo = p
    m =m:gsub("%["," ")
    m =m:gsub("%]"," ")
    myLogger:trace("-> Metadata " .. m)


    -- meta = JSON:decode(m)

    local succ, meta = pcall(function()
        return  JSON:decode(m)
    end)

    if succ then
        -- doStuffWith(data)
    else
        LrDialogs.message("error processing " .. m)
    end


    -- meta = JSON:decode(m)
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
            if (meta["BurstSpeed"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"burstSpeed",tostring(meta["BurstSpeed"]) .. " Images/s") end

            if (meta["FOV"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"fOV",tostring(meta["FOV"])) end
            if (meta["HyperfocalDistance"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"hyperFocal",tostring(meta["HyperfocalDistance"])) end

            if (meta["AccelerometerZ"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"accelerometerz",tostring(meta["AccelerometerZ"])) end
            if (meta["AccelerometerX"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"accelerometerx",tostring(meta["AccelerometerX"])) end
            if (meta["AccelerometerY"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"accelerometery",tostring(meta["AccelerometerY"])) end
            if (meta["CameraOrientation"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"cameraorientation",tostring(meta["CameraOrientation"])) end
            if (meta["RollAngle"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"rollangle",tostring(meta["RollAngle"])) end
            if (meta["PitchAngle"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"pitchangle",tostring(meta["PitchAngle"])) end
            if (meta["FlashFired"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"flashfired",tostring(meta["FlashFired"])) end
            if (meta["FlashBias"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"flashbias",tostring(meta["FlashBias"])) end
            if (meta["FlashCurtain"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"flashcurtain",tostring(meta["FlashCurtain"])) end
            if (meta["LongExposureNoiseReduction"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"longExposurenoisereduction",tostring(meta["LongExposureNoiseReduction"])) end
            if (meta["ImageStabilization"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"imagestabilization",tostring(meta["ImageStabilization"])) end
            if (meta["TimeSincePowerOn"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"timesincepoweron",tostring(meta["TimeSincePowerOn"])) end

            -- added october 2019
            if (meta["BurstMode"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"burstmode",tostring(meta["BurstMode"])) end
            if (meta["MacroMode"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"macromode",tostring(meta["MacroMode"])) end
            if (meta["SequenceNumber"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"sequencenumber",tostring(meta["SequenceNumber"])) end
            if (meta["TimeLapseShotNumber"] ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"timelapsenumber",tostring(meta["TimeLapseShotNumber"])) end
            if (filesize ~= nil ) then photo:setPropertyForPlugin(_PLUGIN,"filesize", string.format("%0.2f", filesize) .. " MB") end

    end
end

UpdateLumixMetadata.showUpdateDialog()