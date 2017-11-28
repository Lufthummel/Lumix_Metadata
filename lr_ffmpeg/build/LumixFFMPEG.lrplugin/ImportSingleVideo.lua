--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 13.05.17
-- Time: 15:20
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
local LrBinding= import 'LrBinding'

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"


local updateProgress = {}

ImportSingleVideo = {}

function ImportSingleVideo.showUpdateDialog()
    -- body of function
    -- LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )

    local currentFileName
    local sep -- file seperator
    local ext

    local startTime = 0.0
    local startTimeString = "0.0"
    local framesString = "1"
    local numberString = ""

    LrFunctionContext.callWithContext('Import Dialog', function(context)

        local properties = LrBinding.makePropertyTable( context )
        properties.format = _G.FORMAT
        properties.framerate = 30
        properties.startframe = 1
        properties.maxframe = 10

        local f = LrView.osFactory()
        local currentPathText = f:static_text {
            title = "Sourcefile: " .. _G.FILEPATH .. "  ",
            alignment = 'left',
            fill_horizontal = 1,
            width_in_chars = 50,
        }

        local outPathText = f:static_text {
            title = "Destination: " .. _G.LRPATH,
            alignment = 'left',
            fill_horizontal = 1,
        }

        local c = f:column {
            spacing = f:control_spacing(),
            bind_to_object = properties,
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Choose file to extract files from',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Select ...',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Temp Dir", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }
                        -- myLogger:trace( "Pfad nach Dialog " .. tmp[1])

                        _G.FILEPATH = string.gsub(tmp[1], [[\]],[[\\]])
                        myLogger:trace( "hallo1")
                        -- win or mac?
                        if (string.find(_G.FILEPATH, [[\]] ) == nil) then

                            _G.SEP =  [[/]]
                        else

                            _G.SEP =  [[\\]]
                        end

                        myLogger:trace( "Selected file " .. _G.FILEPATH)
                        currentPathText.title = "Source " .. _G.FILEPATH
                        pluginPrefs.filepath = _G.FILEPATH
                    end,
                },
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Choose target directory',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Select ...',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Destination Dir", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }
                        myLogger:trace( #tmp .. " -> tmp " .. tmp[1])

                        _G.FILEOUTPATH = string.gsub(tmp[1], [[\]],[[\\]])

                        -- win or mac?
                        if (string.find(_G.FILEOUTPATH, [[\]] ) == nil) then
                            myLogger:trace( "MAC")
                            sep =  [[/]]
                            myLogger:trace( "MAC2" .. sep)
                        else
                            sep = [[\\]]
                            myLogger:trace( "WIN" .. sep)
                        end
                        _G.FILEOUTPATH = _G.FILEOUTPATH .. sep

                        myLogger:trace( " LR dir -> tmp " .. _G.FILEOUTPATH)
                        outPathText.title = "Destination: " .. _G.FILEOUTPATH
                        pluginPrefs.fileoutpath = _G.FILEOUTPATH
                    end,
                },
            },

            f:row {
                spacing = f:control_spacing(),
                f:static_text {

                    title = 'Choose File Format',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:popup_menu {
                    width = 150,
                    items = {
                        { title = "JPEG", value = "jpeg" },
                        { title = "TIFF", value = "tiff" },
                        { title = "PNG", value = "png" },
                        { title = "BMP", value = "bmp" },
                        { title = "HQ-JPEG", value = "hq" },
                    },
                    value = LrView.bind 'format'

                    --
                    -- -- _G.FORMAT = LrView.bind 'format'
                    -- pluginPrefs.format = = LrView.bind 'format'
                },
            },
            f:row {
                currentPathText,
                outPathText,
                f:static_text {
                    title = LrView.bind 'format',

                },
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {

                    title = 'Choose Framerate',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:popup_menu {
                    width = 100,
                    items = {
                        { title = "25", value = 25 },
                        { title = "30", value = 30 },
                        { title = "50", value = 50 },
                        { title = "60", value = 60 },

                    },
                    value = LrView.bind 'framerate',

                    --
                    -- -- _G.FORMAT = LrView.bind 'format'
                    -- pluginPrefs.format = = LrView.bind 'format'
                },
                f:static_text {

                    title = 'Startframe',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:edit_field {
                    fill_horizonal = 1,
                    width_in_chars = 5,
                    immediate = true,
                    alignment = 'right',
                    min = 0,
                    max = 9999,
                    precision = 0,
                    value = LrView.bind( 'startframe' ),
                },

                f:static_text {

                    title = 'Maxframes',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:edit_field {
                    fill_horizonal = 1,
                    width_in_chars = 5,
                    immediate = true,
                    alignment = 'right',
                    min = 1,
                    max = 1000,
                    precision = 0,
                    value = LrView.bind( 'maxframe' ),
                },
            },
        }

        if (LrDialogs.presentModalDialog({title = "Extract Videoframes from File", contents = c, actionVerb = "Go"}) ~= 'cancel' )
        then

            -- myLogger:trace( "-----   Los gehts... " )

            -- caculate the start of stream
            startTime = properties.startframe / properties.framerate
            startTimeString = string.format("%.2f", startTime)
            framesString = string.format("%d", properties.maxframe)
            numberString = string.format("%d", properties.startframe)

            myLogger:trace( "startTime = " .. startTimeString .. " frames " .. framesString)
            _G.FORMAT = properties.format
            pluginPrefs.format = _G.FORMAT
            myLogger:trace( "----->   Single Video ... " .. _G.FORMAT)

            -- LrTasks.startAsyncTask(function ()

            LrFunctionContext.postAsyncTaskWithContext("ProgressAsync", function (context)
                local progressScope = LrDialogs.showModalProgressDialog({
                    title = "Extracting Frames from file...",
                    caption = "test",
                    functionContext = context
                })
                progressScope:setCancelable(false)


                -- local i = 0
                progressScope:setIndeterminate()
                -- progressScope:setPortionComplete(0, 3)


                -- LrTasks.sleep(0)
                --LrDialogs.presentModalDialog(dialogArgs)
                --[[
                for filePath in LrFileUtils.files( _G.VIDEOPATH ) do

                    if progressScope:isCanceled() then
                        myLogger:trace( "BREAK !!!")
                        progressScope:done()
                        break
                    end
                --]]
                    currentFileName = getbasename(_G.FILEPATH)
                    caption = "Processing " .. _G.FILEPATH
                    ext = getextension(_G.FILEPATH)
                    ext = string.upper(ext)
                    newPath = _G.FILEOUTPATH .. currentFileName .. "_" .. _G.FORMAT .. _G.SEP


                    if ( (ext == ".MP4") or (ext == ".MOV")) then
                        myLogger:trace( "MP4 or MOV...")
                        if LrFileUtils.exists(newPath) then
                            myLogger:trace( "file  -> path existiert!!!! " .. newPath)
                            progressScope:setCaption(caption)
                            -- LrFileUtils.createDirectory(newPath)
                            myLogger:trace( "newpath " .. newPath .. " ext: " .. ext .. " :cur filename " .. currentFileName .. " :filepath " .. _G.FILEPATH .. "form " .. _G.FORMAT)
                            -- result = ffprobe(_G.FILEPATH)
                            result = ffmpeg(_G.FILEPATH, currentFileName, newPath, _G.FORMAT, startTimeString, framesString, numberString)
                            myLogger:trace( "result = " .. result)
                        else
                            progressScope:setCaption(caption)
                            LrFileUtils.createDirectory(newPath)
                            myLogger:trace( "newpath " .. newPath .. " ext: " .. ext .. " :cur filename " .. currentFileName .. " :filepath " .. _G.FILEPATH .. "form " .. _G.FORMAT)
                            -- result = ffprobe(_G.FILEPATH)
                            result = ffmpeg(_G.FILEPATH, currentFileName, newPath, _G.FORMAT, startTimeString, framesString, numberString)
                            myLogger:trace( "result = " .. result)
                        end
                    end
                    -- i = i + 1
                    -- i = math.mod(i,4)
                    --progressScope:setPortionComplete(i, 3)

                    myLogger:trace( "file  -> path " .. filePath .. "ext = " .. ext)
                -- end

                progressScope:done()

                LrTasks.sleep(1)
                LrDialogs.message("Background Jobs Finished!")

            end)

        end

    end)



    -- path,file,extension = SplitFilename(tmp[1])
    -- myLogger:trace( #tmp .. " -> path " .. path)
    -- myLogger:trace("split = " ..  getdirectory(tmp[1]) .. " ++  " .. getname(tmp[1]) .. " ++ " .. getbasename(tmp[1]))

end






ImportSingleVideo.showUpdateDialog()

