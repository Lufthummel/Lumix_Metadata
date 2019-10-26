--[[----------------------------------------------------------------------------

Info.lua
HFExporter.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2019 Dr. Holger Kremmin
 All Rights Reserved.

NOTICE:

This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

It can be used for any purpose so long as the copyright notice above,
the web-page links above, and all Author and Version informations are
maintained.

Hope it is useful.

------------------------------------------------------------------------------]]


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

    p.collection = _G.COLLECTION
    p.delete = _G.DELETE

    -- adding observer
    p:addObserver("collection", myObserverFunction)
    p:addObserver("delete", myObserverFunction)

    local pathText = f:static_text {
        title = "Helicon location: " .. _G.HFPATH,
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
            title = "HF Exporting Options",
            bind_to_object = p,
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Click the button to set the path to Helicon Focus executable',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button {
                    width = 150,
                    title = 'Find Helicon',
                    enabled = true,
                    action = function()
                        tmp = LrDialogs.runOpenPanel {title = "Select HF Executable", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }

                        _G.EXIFTOOLPATH = string.gsub(tmp[1], [[\]],[[\\]])
                        pathText.title = "HF location: " .. _G.HFPATH
                        pluginPrefs.hf = _G.HFPATH
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
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = 'Set the collection name',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:edit_field {
                    fill_horizonal = 1,
                    --width_in_chars = 20,
                    value = bind( 'collection' ),-- edit field shows settings value,
                    validate = function(view, value)
                        myLogger:trace( "validate %c  %d ", p.collection, p.delete )
                        _G.COLLECTION = value
                        pluginPrefs.collection = value
                        --tmp = LrDialogs.runOpenPanel {title = "Select HF Executable", canChooseFiles = true, canChooseDirectories = false, allowsMultipleSelection = false }

                        --_G.EXIFTOOLPATH = string.gsub(tmp[1], [[\]],[[\\]])
                        --pathText.title = "HF location: " .. _G.HFPATH
                        --pluginPrefs.hf = _G.HFPATH
                        return true,value
                    end
                },
            },
            f:row {
                --converterToolPathText,
                f:checkbox {
                    title = "Delete tmp files after finishing", -- label text
                    alignment = 'Right',
                    action = function ()
                        myLogger:trace( "check action %c  %d ", p.collection, p.delete )
                    end,
                    -- value = bind ( "delete" ) -- bind button state to data key
                    value = bind {
                        key = "delete",
                        transform = function( value, p )
                            -- body of function
                            myLogger("transform!!!")
                            return value
                        end,
                    }
                },
            },
        },
    }
end

function myObserverFunction()
    myLogger:trace( "observer %c  %d ", p.collection, p.delete )
end

function PluginManager.endDialog(p)
    -- myLogger:trace( "end Dialog " .. p.collection )
end