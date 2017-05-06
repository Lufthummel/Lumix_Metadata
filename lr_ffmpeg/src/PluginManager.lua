--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 15.04.16
-- Time: 19:44
-- To change this template use File | Settings | File Templates.
--

local LrView = import "LrView"
local bind = LrView.bind
local app = import 'LrApplication'
local LrDialogs = import 'LrDialogs'

local LrPrefs = import "LrPrefs"

local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)
local LrLogger = import 'LrLogger'

local myLogger = LrLogger( 'libraryLogger' )

myLogger:enable( "logfile" ) -- or "logfile"

PluginManager = {}

function PluginManager.sectionsForTopOfDialog( f, p )


    local exifToolPathText = f:static_text {
        title = "Exiftool location: " .. _G.EXIFTOOLPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }


    local ffmpegPathText = f:static_text {
        title = "FFMPEG location: " .. _G.FFMPEGPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }

    local videoPathText = f:static_text {
        title = "Video dir: " .. _G.VIDEOPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }

    local lrPathText = f:static_text {
        title = "Lightroom dir: " .. _G.LRPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }
    return {



        -- section for the top of the dialog
        {
            title = "Path to Executabled & Directories",
            f:row {
            spacing = f:control_spacing(),
            f:static_text {
                title = 'Click the button to set the path to exiftool executable',
                alignment = 'left',
                fill_horizontal = 1,
            },
            f:push_button {
                width = 150,
                title = 'Find Exiftool',
                enabled = true,
                action = function()
                    tmp = LrDialogs.runOpenPanel {title = "Select Exiftool Executable", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }

                    _G.EXIFTOOLPATH = string.gsub(tmp[1], [[\]],[[\\]])
                    exifToolPathText.title = "Exiftool location: " .. _G.EXIFTOOLPATH
                    pluginPrefs.exiftool = _G.EXIFTOOLPATH
                end,
            },
        },
            f:row {
                exifToolPathText,
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Click the button to set the path to ffmpeg executable',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Find FFMPEG',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select FFMPEG Executable", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }

                        _G.FFMPEGPATH = string.gsub(tmp[1], [[\]],[[\\]])
                        ffmpegPathText.title = "FFMPEG location: " .. _G.FFMPEGPATH
                        pluginPrefs.ffmpeg = _G.FFMPEGPATH
                    end,
                },
            },
            f:row {
                ffmpegPathText,
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Click the button to set the Lightroom import directory',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Set LR dir',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Lightroom import Dir", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }
                        myLogger:trace( #tmp .. " -> tmp " .. tmp[1])

                        _G.LRPATH = string.gsub(tmp[1], [[\]],[[\\]])

                        -- win or mac?
                        if (string.find(_G.LRPATH, [[\]] ) == nil) then
                            myLogger:trace( "MAC")
                            sep =  [[/]]
                            myLogger:trace( "MAC2" .. sep)
                        else
                            sep = [[\\]]
                            myLogger:trace( "WIN" .. sep)
                        end
                        _G.LRPATH = _G.LRPATH .. sep

                        myLogger:trace( " LR dir -> tmp " .. _G.LRPATH)
                        lrPathText.title = "Lightroom dir: " .. _G.LRPATH
                        pluginPrefs.lrpath = _G.LRPATH
                    end,
                },
            },
            f:row {
                lrPathText,
            },
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Click the button to set the temp directory',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Set default video dir',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Temp Dir", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }
                        myLogger:trace( #tmp .. " -> tmp " .. tmp[1])

                        _G.VIDEOPATH = string.gsub(tmp[1], [[\]],[[\\]])

                        -- win or mac?
                        if (string.find(_G.VIDEOPATH, [[\]] ) == nil) then
                            myLogger:trace( "MAC")
                            sep =  [[/]]
                            myLogger:trace( "MAC2" .. sep)
                        else
                            sep = [[\\]]
                            myLogger:trace( "WIN" .. sep)
                        end
                        _G.VIDEOPATH = _G.VIDEOPATH .. sep

                        myLogger:trace( #tmp .. " -> tmp " .. _G.VIDEOPATH)
                        videoPathText.title = "Default input  dir: " .. _G.VIDEOPATH
                        pluginPrefs.videopath = _G.VIDEOPATH
                    end,
                },
            },
            f:row {
                videoPathText,
            },
        },
    }
end

