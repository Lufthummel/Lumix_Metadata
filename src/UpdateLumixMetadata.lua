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

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "print" ) -- or "logfile"



UpdateLumixMetadata = {}

function UpdateLumixMetadata.showUpdateDialog()
    -- body of function
    LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )
     UpdateLumixMetadata.getPhotos()
end


function UpdateLumixMetadata.getPhotos()
    local catalog = LrApplication.activeCatalog()
    local path = ''
    local fname = ''
    local tmpmeta = ''

    myLogger:trace( "-> getPhotos")
    LrTasks.startAsyncTask(function ()
        local photos = catalog:getMultipleSelectedOrAllPhotos()

        myLogger:trace( "-> getPhotos:startIterating")

        for p,photo in ipairs(photos) do
            path = photo:getRawMetadata("path")
            fname = photo:getFormattedMetadata("fileName")

            myLogger:trace( "-> "..  path .. " + " .. fname )
            tmpmeta = exiftool(path)
            UpdateLumixMetadata.setMetadata(tmpmeta)
        end
    end)


end

function JSON:onDecodeError(message, text, location, etc)
                LrErrors.throwUserError("Internal Error: invalid JSON data" .. message .. text)
end

function UpdateLumixMetadata.setMetadata(m)
    myLogger:trace( "-> setMetadata")
    m =m:gsub("%["," ")
    m =m:gsub("%]"," ")
    myLogger:trace("-> Metadata " .. m)

    local meta = JSON:decode(m)
    myLogger:trace("-> Metadata Lookup " .. meta["ShutterType"])

    for k, v in pairs( meta ) do
        myLogger:trace("-> Metadata " .. k .. " : " .. tostring(v))
    end


end

UpdateLumixMetadata.showUpdateDialog()