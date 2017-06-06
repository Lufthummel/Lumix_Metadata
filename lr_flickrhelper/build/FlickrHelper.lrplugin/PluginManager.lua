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
--[[
function PluginManager.sectionsForTopOfDialog( f, p )


    return {



        -- section for the top of the dialog
        {
            title = "Authorize your Flickr Account",

            f:row {
                spacing = f:control_spacing(),

                f:push_button {
                    width = 150,
                    title = 'Authorize Flickr',
                    enabled = true,
                    action = function()

                        myLogger:trace( "starting OAuth dance...")




                    end,
                },
                f:push_button {
                    width = 150,
                    title = 'DeAutrhorize',
                    enabled = true,
                    action = function()

                        myLogger:trace("cleaning all credentials!!!")


                    end,
                },
            },

        },
    }
end

--]]