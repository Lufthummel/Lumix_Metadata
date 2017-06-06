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

require 'FlickrAPI'
require 'Inspect'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"


local updateProgress = {}

UpdateFlickrMetadata = {}

function UpdateFlickrMetadata.showUpdateDialog()
    -- body of function
    -- LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )

    if (LrDialogs.confirm("Update Flickr Metadata","Do you want to update Metadata?","Sure","Cancel") == "ok")
    then

    -- enable progress bar

        updateProgress = LrProgressScope({
         title = "Update Flickr Metadata",
        })
            updateProgress:setCancelable(true)
            UpdateFlickrMetadata.getPhotos()
    end
end

function UpdateFlickrMetadata.getPhotos()
    local catalog = LrApplication.activeCatalog()


    LrTasks.startAsyncTask(function ()
        local count = 0
        updateProgress:setPortionComplete( 1, 2 )
        local collections = catalog:getPublishServices( 'com.adobe.lightroom.export.flickr' )  --Retrieves the publish services defined by lr flickr plug-in

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

                        if tmpphoto:getPropertyForPlugin(_PLUGIN,"remoteid") == nil then

                            if tmpid == nil then
                                tmpid = "-"
                                sizeurl = "-"
                            else
                                tmpjson = FlickrAPI.getSizes( tmpid )

                                if tmpurl == nil then tmpurl = "-" end
                                myLogger:trace( "id = " .. tmpid .. " url = " .. tmpurl )

                                catalog:withWriteAccessDo( "UpdateMetada", function( context )

                                    UpdateFlickrMetadata.setBBCode(tmpjson, tmpphoto, tmpid, tmpurl)
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


function UpdateFlickrMetadata.setBBCode(json, tmpphoto, tmpid, tmpurl)

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


    local sizes = JSON:decode(json)
    local size = { sizes.sizes.size }
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

    tmpphoto:setPropertyForPlugin(_PLUGIN,"remoteid",tmpid)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"flickrurl",tmpurl)
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

    myLogger:trace(bbcode .. cr .. bbextra)

    tmpphoto:setPropertyForPlugin(_PLUGIN,"bbshort",bbcode)
    tmpphoto:setPropertyForPlugin(_PLUGIN,"bblong",bbcode .. cr .. bbextra)

end


UpdateFlickrMetadata.showUpdateDialog()

