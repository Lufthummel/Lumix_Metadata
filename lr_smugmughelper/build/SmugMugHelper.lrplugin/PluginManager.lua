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
myLogger:enable( "logfile" )

require 'SmugMugOAuth'
PluginManager = {}

function PluginManager.sectionsForTopOfDialog( f, p )


    return {



        -- section for the top of the dialog
        {
            title = "Authorize your SmugMug Account",

            f:row {
                spacing = f:control_spacing(),

                f:push_button {
                    width = 200,
                    title = 'Authorize SmugMug Account',
                    enabled = not _G.AUTHORIZED,
                    action = function()

                        myLogger:trace( "starting OAuth dance...")
                        SmugMugOAuth.authorize()



                    end,
                },
                f:push_button {
                    width = 200,
                    title = 'DeAutrhorize',
                    enabled = _G.AUTHORIZED,
                    action = function()

                        myLogger:trace("cleaning all credentials!!!")
                        pluginPrefs.accesstoken = ''

                    end,
                },
            },

        },
    }
end

