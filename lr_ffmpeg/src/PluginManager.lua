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

    myLogger:trace( "top Dialog")
    local converterToolPathText = f:static_text {
        title = "Image converter location: " .. _G.CONVERTERPATH,
        alignment = 'left',
        fill_horizontal = 1,
    }

    p.hqEnabled = false


    return {

        -- section for the top of the dialog
        {
            title = "Path to Executabled & Directories",
            bind_to_object = p,
            f:row {
            spacing = f:control_spacing(),
            f:static_text {
                title = 'Click the button to set the path to image converter executable',
                alignment = 'left',
                fill_horizontal = 1,
            },
            f:push_button {
                width = 150,
                title = 'Find GraphicsMagick',
                enabled = true,
                action = function()
                    tmp = LrDialogs.runOpenPanel {title = "Select Converter Executable", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }

                    _G.CONVERTERPATH = string.gsub(tmp[1], [[\]],[[\\]])
                    converterToolPathText.title = "Exiftool location: " .. _G.EXIFTOOLPATH
                    pluginPrefs.converter = _G.CONVERTERPATH
                end,
            },
        },
            f:row {
                converterToolPathText,
                f:checkbox {
                    title = "Enable HQ Mode", -- label text
                    alignment = 'Right',
                    value = bind( "hqEnabled" ) -- bind button state to data key
                },
            },

        },

    }



end

function PluginManager.sectionsForBottomOfDialog(f,p)

    license = "This Plugin is licensed under the WTF license. So unless you are planning to use it for building " ..
              "an atomic bomb or any other violent tool you can use for what ever you want" ..
              "This Plugin includes executables of FFMPEG and Exiftool in unmodified form" ..
              "For license terms of FFMPEG please visit www.ffmpeg.org" ..
              "License terms of Exiftool are mentioned here: http://www.sno.phy.queensu.ca/~phil/exiftool/#license" ..
              "The Author of the plugin takes no responsibilities for the use of the tool. It is seen as work in progress" ..
              "So it is a good idea to back up your computer - if something went wrong it is not my fault" ..
              "If you like the tool please share the link to it and write something positive about it"


    myLogger:trace( "bottom Dialog")
    return {
        {
            title = "License",
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                title = license,
                alignment = 'left',
                fill_horizontal = 1,
                }
            }
        }
    }

end

function PluginManager.endDialog(p)
    -- myLogger:trace( "end Dialog " .. p.hqenabled )
end