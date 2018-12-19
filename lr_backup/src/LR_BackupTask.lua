--[[----------------------------------------------------------------------------

LR_BackupTask.lua
Backup Jpegs in High Quality, Thumbnails and related Raws/XMP to selected folder

--------------------------------------------------------------------------------
(c) Dr. Holger Kremmin
licensed under the "WhatTheFuck" License. Unless you use this software to kill any
animal or human being do what you want with this software

------------------------------------------------------------------------------]]

-- Lightroom API
local LrPathUtils = import 'LrPathUtils'
--local LrCollection = import 'LrCollection'
local LrDate = import 'LrDate'
local LrFileUtils = import 'LrFileUtils'
local LrErrors = import 'LrErrors'
local LrDialogs = import 'LrDialogs'
local LrPathUtils = import 'LrPathUtils'
local LrLogger = import 'LrLogger'
local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"

--============================================================================--

LR_BackupTask = {}

--------------------------------------------------------------------------------

function LR_BackupTask.processRenderedPhotos( functionContext, exportContext )

	-- Make a local reference to the export parameters.
	
	local exportSession = exportContext.exportSession
	local exportParams = exportContext.propertyTable

	
	-- Set progress title.

	local nPhotos = exportSession:countRenditions()

	local progressScope = exportContext:configureProgress {
						title = nPhotos > 1
							   and LOC( "$$$/LR_Backup/Upload/Progress=Backup ^1 photos to Backup Folder", nPhotos )
							   or LOC "$$$/LR_Backup/Upload/Progress/One=Backup one photo to Backup Folder",
					}

    local path = exportParams.path

    --local collectionName = LrCollection.getName()
    --myLogger:trace("collection name")
    --myLogger:trace(collectionName)
	
	-- Ensure target directory exists.
	
	local index = 0
	while true do
		

        myLogger:trace("path for export" .. path)
		
		local exists = LrFileUtils.exists(path)
		
		if exists == false then

				-- This is a possible situation if permissions don't allow us to create directories.
				
				LrErrors.throwUserError( LOC "$$$/LR_Backup/Upload/Errors/DirNotExist=Backup folder not existing" )

			
		elseif exists == 'file' then
		
			-- Unlikely, due to the ambiguous way paths for directories get tossed around.
			
			LrErrors.throwUserError( LOC "$$$/LR_Backup/Upload/Errors/UploadDestinationIsAFile=Cannot backup to a destination that already exists as a file." )
		elseif exists == 'directory' then
		
			-- Excellent, it exists, do nothing here.
			
		else
		
			-- Not sure if this would every really happen.
			
			LrErrors.throwUserError( LOC "$$$/LR_Backup/Upload/Errors/CannotCheckForDestination=Unable to backup because Lightroom cannot ascertain if the target destination exists." )
		end
		
		if index == nil then
			break
		end
		
		index = string.find( exportParams.path, "/", index + 1 )
		
    end

    -- create backup directory at export path
    local backupdirname = "backup_" .. LrDate.timeToUserFormat(LrDate.currentTime(), '%Y%m%d%H%M%S')
    local backupdir = LrPathUtils.child( path, backupdirname )
    LrFileUtils.createDirectory(backupdir)

    local exists = LrFileUtils.exists(backupdir)

    if exists == false then

        -- This is a possible situation if permissions don't allow us to create directories.

        LrErrors.throwUserError( LOC "$$$/LR_Backup/Upload/Errors/BackupDirNotCreated=Backup folder not created" )

    end


    myLogger:trace("backupdir  " .. backupdir)

    local rawdir = LrPathUtils.child( backupdir, 'raw' )
    LrFileUtils.createDirectory(rawdir)

    local picdir = LrPathUtils.child( backupdir, 'pictures' )
    LrFileUtils.createDirectory(picdir)

    myLogger:trace("subdir  " .. rawdir .. " " .. picdir)

        myLogger:trace("starting export")
	-- Iterate through photo renditions.
	
	local failures = {}

	for _, rendition in exportContext:renditions{ stopIfCanceled = true } do

        local photo = rendition.photo
        local rawphoto = photo:getRawMetadata("path")

        local rawfilename = LrPathUtils.leafName(rawphoto)

        local rawfile = LrPathUtils.child( rawdir, rawfilename )
        myLogger:trace("copy raw  " .. rawphoto .. " to " .. rawfile)
        suc, msg = LrFileUtils.copy(rawphoto, rawfile)
        myLogger:trace( suc )
        myLogger:trace(msg)

        -- xmp handling
        xmpphoto = LrPathUtils.replaceExtension( rawphoto, 'xmp' )
        xmpfile = LrPathUtils.replaceExtension( rawfile, 'xmp' )

        if LrFileUtils.exists(xmpphoto) then
            myLogger:trace("copy xmp  " .. xmpphoto .. " to " .. xmpfile)
            suc, msg = LrFileUtils.copy(xmpphoto, xmpfile)
            myLogger:trace( suc )
            myLogger:trace(msg)
        end

		-- Wait for next photo to render.

		local success, pathOrMessage = rendition:waitForRender()
		
		-- Check for cancellation again after photo has been rendered.
		
		if progressScope:isCanceled() then break end
		
		if success then

			myLogger:trace("processing " .. pathOrMessage)
			local filename = LrPathUtils.leafName( pathOrMessage )
            local picfile = LrPathUtils.child( picdir, filename )
			-- copy rendered image
			myLogger:trace("copy rendered image " .. pathOrMessage .. " to " .. picfile)
			suc, msg = LrFileUtils.copy(pathOrMessage, picfile)

            myLogger:trace( suc )
            myLogger:trace(msg)
            -- generate thumbnail
            -- callback function for request thumbnail

            local f = function(jpg, err)
                if err == nil then
                    local fileName = LrPathUtils.leafName(rawphoto)
                    local tmppath = LrPathUtils.child(backupdir, fileName)
                    local jpgpath = LrPathUtils.addExtension(tmppath, 'jpg')
                    myLogger:trace("thumbnail image " .. jpgpath)
                    local out = io.open(jpgpath, 'wb')
                    io.output(out)
                    io.write(jpg)
                    io.close(out)
                end
            end

            local thumbs = exportParams.thumbnails

            if thumbs then
                photo:requestJpegThumbnail(320, 320, f)
            end
			
			LrFileUtils.delete( pathOrMessage )
					
		end
		
	end


	
	if #failures > 0 then
		local message
		if #failures == 1 then
			message = LOC "$$$/FtpUpload/Upload/Errors/OneFileFailed=1 file failed to upload correctly."
		else
			message = LOC ( "$$$/FtpUpload/Upload/Errors/SomeFileFailed=^1 files failed to upload correctly.", #failures )
		end
		LrDialogs.message( message, table.concat( failures, "\n" ) )
	end
	
end
