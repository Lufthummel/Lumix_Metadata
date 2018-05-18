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
--local Inspect = assert(loadfile (LrPathUtils.child(_PLUGIN.path, "Inspect.lua")))() -- one-time load of the routines

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'

require 'SmugMugAPI'
require 'Inspect'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"


local updateProgress = {}

UpdateSmugMugMetadata = {}

function UpdateSmugMugMetadata.showUpdateDialog()

    action = LrDialogs.confirm("Update SmugMug Metadata","Do you want to update Metadata?","Update","Cancel", "Force")

    if action == "ok"  then
        updateProgress = LrProgressScope({
         title = "Update SmugMug Metadata",
        })
            updateProgress:setCancelable(true)
            UpdateSmugMugMetadata.getPhotos(false)
    elseif action == "other" then
        updateProgress = LrProgressScope({
            title = "Update SmugMug Metadata",
        })
        updateProgress:setCancelable(true)
        UpdateSmugMugMetadata.getPhotos(true)
    end

end

function UpdateSmugMugMetadata.getPhotos(force)
    local catalog = LrApplication.activeCatalog()


    LrTasks.startAsyncTask(function ()
        local count = 0
        updateProgress:setPortionComplete( 1, 2 )
        local collections = catalog:getPublishServices( 'com.smugmug.lightroom.publish' )  --Retrieves the publish services defined by lr flickr plug-in

        for i,collection in ipairs(collections) do -- iterate over all collections created by flickr plugin, at least one
            -- s = s .. " " .. c:getName()
            name = collection:getName() -- -> name of collection
            myLogger:trace( "name of collection = " .. name)

                for i, cc in ipairs(collection:getChildCollections()) do  -- folders of collection aka child collections

                    for i, publishedPhoto in ipairs(cc:getPublishedPhotos()) do

                        if updateProgress:isCanceled() then
                            updateProgress:done()
                           -- myLogger:trace( "-> cancelled")
                            return

                        end

                        tmpid = publishedPhoto:getRemoteId()
                        tmpurl = publishedPhoto:getRemoteUrl()
                        tmpphoto = publishedPhoto:getPhoto()

                        if ( tmpphoto:getPropertyForPlugin(_PLUGIN,"remoteid") == nil) or force == true then

                            if tmpid == nil then
                                tmpid = "-"
                                sizeurl = "-"
                            else
                                tmpjson = FlickrAPI.getSizes( tmpid )

                                if tmpurl == nil then tmpurl = "-" end
                                -- myLogger:trace( "id = " .. tmpid .. " url = " .. tmpurl )

                                catalog:withWriteAccessDo( "UpdateMetada", function( context )

                                    UpdateSmugMugMetadata.setBBCode(tmpjson, tmpphoto, tmpid, tmpurl)
                                    publishedPhoto:setEditedFlag( false )
                                    count = count +1

                                -- myLogger:trace( "-> updated")
                                end)
                            end
                        end
                    end

                end
        end
        updateProgress:done()
        LrDialogs.message(string.format("Finished adding Flickr Metadata to %04d images", count ))
    end)
end


function UpdateSmugMugMetadata.setBBCode(json, tmpphoto, tmpid, tmpurl)

    local title = "Untitled"
    local shsp = "--"
    local aperture = "-.-"
    local iso = "-"
    local make = ""
    local camera = "?"
    local lens = "?"
    local focal = "-"
    local caption = ""
    local cr = "\n"

    local medium = ""
    local large = ""
    local original = ""

    local status = ""
    local size


    local sizes = JSON:decode(json)
    if sizes == nil then return end
    -- myLogger:trace("-> Status " .. sizes["stat"])

    if pcall(function () status = sizes["stat"] end ) then
        if status ~= "ok" then
            myLogger:trace("-> Status " .. sizes["stat"])
            myLogger:trace("-> id =  " .. tmpid)
            return
        end

    else
        myLogger:trace("-> problem in pcall ")
        myLogger:trace("-> id =  " .. tmpid)
        return
    end

    --local size = { sizes.sizes.size }

    if pcall(function () size = { sizes.sizes.size } end ) then

        -- myLogger:trace(Inspect.inspectTable(size))
        for i, line in ipairs(size) do
            for i, subline in ipairs(line) do

                if subline.label == "Medium" then
                    medium = subline.source
                elseif subline.label == "Large" then
                    large = subline.source
                elseif subline.label == "Original" then
                    original = subline.source
                end

                -- myLogger:trace(Inspect.inspectTable(subline))
                -- myLogger:trace("-> Metadata " .. subline.label)

            end

        end
    else
        return
    end


    tmpphoto:setPropertyForPlugin(_PLUGIN,"remoteid",tmpid)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"smugurl",tmpurl)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"staticmedium",medium)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"staticlarge",large)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"staticoriginal",original)


    if tmpphoto:getFormattedMetadata( "title" ) ~= nil then title = tmpphoto:getFormattedMetadata( "title" ) end
    if tmpphoto:getFormattedMetadata( "shutterSpeed" ) ~= nil then shsp = tmpphoto:getFormattedMetadata( "shutterSpeed" ) end
    if tmpphoto:getFormattedMetadata( "aperture" ) ~= nil then aperture = tmpphoto:getFormattedMetadata( "aperture" ) end
    if tmpphoto:getFormattedMetadata( "isoSpeedRating" ) ~= nil then iso = tmpphoto:getFormattedMetadata( "isoSpeedRating" ) end
    if tmpphoto:getFormattedMetadata( "cameraModel" ) ~= nil then camera = tmpphoto:getFormattedMetadata( "cameraModel" ) end
    if tmpphoto:getFormattedMetadata( "lens" ) ~= nil then lens = tmpphoto:getFormattedMetadata( "lens" ) end
    if tmpphoto:getFormattedMetadata( "focalLength" ) ~= nil then focal = tmpphoto:getFormattedMetadata( "focalLength" ) end
    if tmpphoto:getFormattedMetadata( "caption" ) ~= nil then caption = tmpphoto:getFormattedMetadata( "caption" ) end
    if tmpphoto:getFormattedMetadata( "cameraMake" ) ~= nil then make = tmpphoto:getFormattedMetadata( "cameraMake" ) end

    local bbextra = make .. " " .. camera .. " with " .. lens .. " at " .. focal .. cr .. shsp .. " , " .. aperture .. " , " .. iso .. cr .. caption


    local bbcode = string.format("[url=%s][img]%s[/img][/url]\n[url=%s]%s[/url]", tmpurl,
                    large, tmpurl, title)

    -- myLogger:trace(bbcode .. cr .. bbextra)

    tmpphoto:setPropertyForPlugin(_PLUGIN,"bbshort",bbcode)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"bblong",bbcode .. cr .. bbextra)

end


UpdateSmugMugMetadata.showUpdateDialog()

