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




    return {




    }
end

