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



PluginManager = {}

function PluginManager.sectionsForTopOfDialog( f, p )


    local pathText = f:static_text {
        title = "Exiftool location: " .. _G.EXIFTOOLPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }

    local tmppathText = f:static_text {
        title = "Temp dir: " .. _G.TMPPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }

    return {



        -- section for the top of the dialog
        {
            title = "Path to Exiftool Executable",
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
                        pathText.title = "Exiftool location: " .. _G.EXIFTOOLPATH
                        pluginPrefs.exiftool = _G.EXIFTOOLPATH
                    end,
                },
            },
            f:row {

                pathText,
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
                    title = 'Set temp dir',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select Temp Dir", canChooseFiles = false, canChooseDirectories = true, allowsMultipleSelection = false }
                        myLogger:trace( #tmp .. " -> tmp " .. tmp[1])

                        _G.TMPPATH = string.gsub(tmp[1], [[\]],[[\\]])

                        -- win or mac?
                        if (string.find(_G.TMPPATH, [[\]] ) == nil) then
                            myLogger:trace( "MAC")
                            sep =  [[/]]
                            myLogger:trace( "MAC2" .. sep)
                        else
                            sep = [[\\]]
                            myLogger:trace( "WIN" .. sep)
                        end
                        _G.TMPPATH = _G.TMPPATH .. sep

                        myLogger:trace( #tmp .. " -> tmp " .. _G.TMPPATH)
                        tmppathText.title = "Temp dir: " .. _G.TMPPATH
                        pluginPrefs.tmppath = _G.TMPPATH
                    end,
                },
            },
            f:row {

                tmppathText,
            },
        },
    }
end

