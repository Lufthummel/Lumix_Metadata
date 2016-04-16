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

                        _G.EXIFTOOLPATH = tmp[1]
                        pathText.title = "Exiftool location: " .. _G.EXIFTOOLPATH
                        pluginPrefs.exiftool = _G.EXIFTOOLPATH
                    end,
                },
            },
            f:row {
                f:static_text {
                    title = bind 'exifpath',
                    alignment = 'left',
                },
                pathText,
            },
        },
    }
end

