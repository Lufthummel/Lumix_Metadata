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
local LrView = import 'LrView'
local LrFileUtils = import 'LrFileUtils'
local LrPrefs = import "LrPrefs"
local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"


local updateProgress = {}

ImportVideo = {}

function ImportVideo.showUpdateDialog()
    -- body of function
    -- LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )

    local currentFileName
    local sep -- file seperator
    local ext

    LrFunctionContext.callWithContext('Import Dialog', function(context)


        local f = LrView.osFactory()
        local currentPathText = f:static_text {
            title = "Source " .. _G.VIDEOPATH,
            alignment = 'left',
            fill_horizontal = 1,
            width_in_chars = 50,
        }
        local c = f:column {
            spacing = f:control_spacing(),
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Choose directory to extract files from',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Select ...',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Temp Dir", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }
                        -- myLogger:trace( "Pfad nach Dialog " .. tmp[1])

                        _G.VIDEOPATH = string.gsub(tmp[1], [[\]],[[\\]])
                        myLogger:trace( "hallo1")
                        -- win or mac?
                        if (string.find(_G.VIDEOPATH, [[\]] ) == nil) then

                            _G.SEP =  [[/]]
                        else

                            _G.SEP =  [[\\]]
                        end
                        myLogger:trace( "hallo2")
                        _G.VIDEOPATH = _G.VIDEOPATH .. _G.SEP

                        myLogger:trace( "new extraction dir " .. _G.VIDEOPATH)
                        currentPathText.title = "Source " .. _G.VIDEOPATH
                        pluginPrefs.videopath = _G.VIDEOPATH
                    end,
                },
            },
            f:row {
                currentPathText,
            }
        }

        if (LrDialogs.presentModalDialog({title = "Extract Videoframes", contents = c, actionVerb = "Go"}))
            then

            myLogger:trace( "-----   Los gehts...")

            -- LrTasks.startAsyncTask(function ()

            LrFunctionContext.postAsyncTaskWithContext("ProgressAsync", function (context)
                local progressScope = LrDialogs.showModalProgressDialog({
                    title = "Extracting Frames...",
                    caption = "test",
                    functionContext = context
                })
                progressScope:setCancelable(true)


                    -- local i = 0
                    progressScope:setIndeterminate()
                    -- progressScope:setPortionComplete(0, 3)


                    -- LrTasks.sleep(0)
                    --LrDialogs.presentModalDialog(dialogArgs)

                    for filePath in LrFileUtils.files( _G.VIDEOPATH ) do

                        if progressScope:isCanceled() then
                            myLogger:trace( "BREAK !!!")
                            progressScope:done()
                            break
                        end

                        currentFileName = getbasename(filePath)
                        caption = "Processing " .. currentFileName
                        ext = getextension(filePath)

                        newPath = _G.LRPATH .. currentFileName ..  _G.SEP

                        if ( (ext == ".MP4") or (ext == ".MOV")) then
                            myLogger:trace( "MP4 or MOV...")
                            if LrFileUtils.exists(newPath) then
                                myLogger:trace( "file  -> path existiert!!!! " .. filePath)
                            else
                                progressScope:setCaption(caption)
                                LrFileUtils.createDirectory(newPath)
                                result = ffmpeg(filePath, currentFileName, newPath)
                                myLogger:trace( "result = " .. result)
                            end
                        end
                        -- i = i + 1
                        -- i = math.mod(i,4)
                        --progressScope:setPortionComplete(i, 3)

                        myLogger:trace( "file  -> path " .. filePath .. "ext = " .. ext)
                    end

                    progressScope:done()

                    LrTasks.sleep(1)
                    LrDialogs.message("done")

                end)
            end

    end)



    -- path,file,extension = SplitFilename(tmp[1])
    -- myLogger:trace( #tmp .. " -> path " .. path)
    -- myLogger:trace("split = " ..  getdirectory(tmp[1]) .. " ++  " .. getname(tmp[1]) .. " ++ " .. getbasename(tmp[1]))

end






ImportVideo.showUpdateDialog()