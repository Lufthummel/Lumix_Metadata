--
-- Created by IntelliJ IDEA.
-- User: hkremmin
-- Date: 15.04.16
-- Time: 19:36
-- To change this template use File | Settings | File Templates.
--

require 'keys.lua'  -- consumer & secret, values are not stored in GIT

local LrPrefs = import "LrPrefs"
local pluginPrefs = LrPrefs.prefsForPlugin(_PLUGIN)

-- check after startup if already authenticated and load access token
if (pluginPrefs.accesstoken == nil) then

    _G.ACCESSTOKEN = ''

else
    _G.ACCESSTOKEN = pluginPrefs.accesstoken
end

if (pluginPrefs.authorized == nil) then

    _G.AUTHORIZED = false

else
    _G.AUTHORIZED = pluginPrefs.authorized
end

