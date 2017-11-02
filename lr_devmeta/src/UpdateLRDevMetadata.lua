--
-- Created by IntelliJ IDEA.
-- User: imac
-- Date: 06.09.15
-- Time: 19:42
-- To change this template use File | Settings | File Templates.
--
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'

-- local myLogger = LrLogger( 'libraryLogger' )
-- myLogger:enable( "print" ) -- or "logfile"


local updateProgress = {}

UpdateDevMetadata = {}
local CR = '\n'
local luminance  = ''
local hue = ''
local saturation = ''
local enabled = ''
local other = ''
local twenty12 = ''
local curve = ''
local parametric = ''

local crop = ''
local perspective = ''
local retouch = ''
local redeye = ''
local processVersion = ''


function UpdateDevMetadata.showUpdateDialog()
    -- body of function
    -- LrDialogs.message( "Update Lumix Metadata", "Hello World!", "info" )

    if (LrDialogs.confirm("Update Dev Metadata","Do you want to update Metadata?","Sure","Cancel") == "ok")
    then

    -- enable progress bar

        updateProgress = LrProgressScope({
         title = "Update Dev Metadata",
        })
        updateProgress:setCancelable(true)

        UpdateDevMetadata.getPhotos()
    end
end


function UpdateDevMetadata.getPhotos()
    local catalog = LrApplication.activeCatalog()


    local t = 0

    -- myLogger:trace( "-> getPhotos")
    LrTasks.startAsyncTask(function ()
        local photos = catalog:getMultipleSelectedOrAllPhotos()
        local totalphotos = #photos

        updateProgress:setPortionComplete(t, totalphotos)

        for p,photo in ipairs(photos) do

            if updateProgress:isCanceled() then
                updateProgress:done()

                return

            end
            catalog:withWriteAccessDo( "UpdateMetada", function( context )
                UpdateDevMetadata.setMetadata(photo)
            end)
            t = t + 1
            updateProgress:setPortionComplete(t, totalphotos)
        end
        updateProgress:done()
    end)


end


function  dump(o)
    if type(o) == 'table' then

        for k,v in pairs(o) do
            -- if type(k) ~= 'number' then k = '"'..k..'"' end

            if string.find(k, "Luminance") then
                luminance = luminance .. k.. ': ' ..v .. CR
            elseif string.find(k, "Hue") then
                hue = hue .. k.. ': ' ..v .. CR
            elseif string.find(k, "ProcessVersion") then
                processVersion = v
            elseif string.find(k, "ToneCurve") then
                    if type(v) ~= 'table'
                    then
                        curve = curve .. k.. ': ' .. tostring(v) .. CR
                    else
                        curve = curve .. k .. ':' ..  dumpCurve(v)
                    end
            elseif string.find(k, "Retouch") then
                if type(v) ~= 'table'
                then
                    retouch = retouch .. k.. ': ' .. tostring(v) .. CR
                else
                    retouch = retouch .. k .. ':' ..  dumpCurve(v)
                end
            elseif string.find(k, "RedEye") then
                if type(v) ~= 'table'
                then
                    redeye = redeye .. k.. ': ' .. tostring(v) .. CR
                else
                    redeye = redeye .. k .. ':' ..  dumpCurve(v)
                end
            elseif string.find(k, "Crop") then
                crop = crop .. k.. ': ' .. tostring(v) .. CR
            elseif string.find(k, "Perspective") then
                perspective = perspective .. k.. ': ' .. tostring(v) .. CR
            elseif string.find(k, "2012") then
                if type(k) ~= 'table' then twenty12 = twenty12 .. k.. ': ' .. tostring(v) .. CR end
            elseif string.find(k, "Parametric") then
                parametric = parametric .. k.. ': ' .. tostring(v) .. CR
            elseif string.find(k, "Saturation") then
                saturation = saturation .. k.. ': ' ..v .. CR
            elseif (string.find(k, "Enable")  or  string.find(k, "Auto") ) then
                enabled = enabled .. k.. ': ' .. tostring(v) .. CR
            else
                if type(k) ~= 'table' then other = other .. k.. ': ' .. tostring(v) .. CR end
            end
            -- s = s .. '['..k..'] = ' .. dump(v) .. ','
        end

    else
        return tostring(o)
    end
end

function dumpCurve(o)
    if type(o) == 'table' then
        local s = ''
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s
    else
        return tostring(o)
    end
end

function UpdateDevMetadata.setMetadata(p)

    local photo = p

    local settings = photo:getDevelopSettings()
    luminance  = ''
    hue = ''
    saturation = ''
    enabled = ''
    other = ''
    twenty12 = ''
    curve = ''
    parametric = ''
    crop = ''
    perspective = ''
    retouch = ''
    redeye = ''
    processVersion = ''

    dump(settings)

    photo:setPropertyForPlugin(_PLUGIN,"hue",hue)
    photo:setPropertyForPlugin(_PLUGIN,"saturation",saturation)
    photo:setPropertyForPlugin(_PLUGIN,"luminance",luminance)
    photo:setPropertyForPlugin(_PLUGIN,"enabled",enabled)
    photo:setPropertyForPlugin(_PLUGIN,"other",other)
    photo:setPropertyForPlugin(_PLUGIN,"twentytwelve",twenty12)
    photo:setPropertyForPlugin(_PLUGIN,"curve",curve)
    photo:setPropertyForPlugin(_PLUGIN,"parametric",parametric)
    photo:setPropertyForPlugin(_PLUGIN,"perspective",perspective)
    photo:setPropertyForPlugin(_PLUGIN,"crop",crop)
    photo:setPropertyForPlugin(_PLUGIN,"retouch",retouch)
    photo:setPropertyForPlugin(_PLUGIN,"redeye",redeye)
    photo:setPropertyForPlugin(_PLUGIN,"processVersion",processVersion)

end

UpdateDevMetadata.showUpdateDialog()