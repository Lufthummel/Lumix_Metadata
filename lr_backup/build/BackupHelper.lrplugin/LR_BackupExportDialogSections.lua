--[[----------------------------------------------------------------------------

Backup Jpegs in High Quality, Thumbnails and related Raws/XMP to selected folder

--------------------------------------------------------------------------------
(c) Dr. Holger Kremmin
licensed under the "WhatTheFuck" License. Unless you use this software to kill any
animal or human being do what you want with this software

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrView = import 'LrView'
local LrDialogs = import 'LrDialogs'
local LrLogger = import 'LrLogger'
local myLogger = LrLogger( 'libraryLogger' )
local LrPathUtils = import 'LrPathUtils'
myLogger:enable( "logfile" ) -- or "logfile"

--============================================================================--

LR_BackupExportDialogSections = {}

-------------------------------------------------------------------------------

local function updateExportStatus( propertyTable )

    -- myLogger:trace("update export path " .. propertyTable.path)
	local message = nil
	
	repeat
		-- Use a repeat loop to allow easy way to "break" out.
		-- (It only goes through once.)

		
		if ( propertyTable.path == "" or propertyTable.path == nil ) then
			message = LOC "$$$/LR_Backup/ExportDialog/Messages/EnterPath=Enter a destination path"
			break
		end
		
	until true
	
	if message then
		propertyTable.message = message
		propertyTable.hasError = true
		propertyTable.hasNoError = false
		propertyTable.LR_cantExportBecause = message
	else
		propertyTable.message = nil
		propertyTable.hasError = false
		propertyTable.hasNoError = true
		propertyTable.LR_cantExportBecause = nil
	end
	
end

-------------------------------------------------------------------------------

function LR_BackupExportDialogSections.startDialog( propertyTable )
	
	propertyTable:addObserver( 'items', updateExportStatus )
	propertyTable:addObserver( 'path', updateExportStatus )
	propertyTable:addObserver( 'thumbnails', updateExportStatus )
	-- propertyTable:addObserver( 'ftpPreset', updateExportStatus )

	updateExportStatus( propertyTable )
	
end

-------------------------------------------------------------------------------

function LR_BackupExportDialogSections.sectionsForBottomOfDialog( _, propertyTable )

	local f = LrView.osFactory()
	local bind = LrView.bind
	local share = LrView.share

    -- local exportPath = bind { key = 'exportPath', object = propertyTable }

	local result = {
	
		{
			title = LOC "$$$/LR_Backup/ExportDialog/BackupSettings=Backup Settings",
			
			--synopsis = bind { key = 'exportPath', object = propertyTable },


			f:row {
				f:static_text {
					title = LOC "$$$/LR_Backup/ExportDialog/Destination=Destination:",
					alignment = 'right',
					width = share 'labelWidth'
				},

				f:push_button {
					width = 200,
					title = 'Select Export Folder',
					enabled = true,

					action = function()
                        -- myLogger:trace("set export path")

                        tmp = LrDialogs.runOpenPanel {title = "Select Backup Folder", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }

                        propertyTable.path = LrPathUtils.standardizePath(string.gsub(tmp[1], [[\]],[[\\]]))

                       -- myLogger:trace("export path = " .. selectedpath)



					end,
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth'
				},
	
				f:checkbox {
					title = LOC "$$$/LR_Backup/ExportDialog/CreateThumbnails=Create Thumbnails",
					value = bind 'thumbnails',
				},
			},

            f:row {
                f:static_text {
                    title = LOC "$$$/LR_Backup/ExportDialog/BackupPath=Backup Path:",
                    alignment = 'right',
                    width = share 'labelWidth',
                    visible = bind 'hasNoError',
                },

                f:static_text {
                    fill_horizontal = 1,
                    width_in_chars = 20,
                    title = bind 'path',
                    -- visible = bind 'hasNoError',
                },
            },

            f:row {
                f:static_text {
                    fill_horizontal = 1,
                    title = bind 'message',
                    -- visible = bind 'hasError',
                },
            },

		},
	}

	return result
	
end
