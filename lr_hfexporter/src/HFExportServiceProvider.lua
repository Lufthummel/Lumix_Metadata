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


local LrApplication     = import("LrApplication")
local LrDialogs         = import("LrDialogs")
local LrTasks           = import("LrTasks")
local LrFileUtils       = import("LrFileUtils")
local LrPathUtils       = import("LrPathUtils")
local LrLogger          = import("LrLogger")

local myLogger = LrLogger("libraryLogger")
myLogger:enable("logfile")

trimr = function(s)
    -- function num : 0_1
    if not s:find("^%s*$") or not "" then
        return s:match("^(.*%S)")
    end
end

function dump(o)
    myLogger:trace("type = %t", type(o))
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function format_any_value(obj, buffer)
    local _type = type(obj)
    if _type == "table" then
        buffer[#buffer + 1] = '{"'
        for key, value in next, obj, nil do
            buffer[#buffer + 1] = tostring(key) .. '":'
            format_any_value(value, buffer)
            buffer[#buffer + 1] = ',"'
        end
        buffer[#buffer] = '}' -- note the overwrite
    elseif _type == "string" then
        buffer[#buffer + 1] = '"' .. obj .. '"'
    elseif _type == "boolean" or _type == "number" then
        buffer[#buffer + 1] = tostring(obj)
    else
        buffer[#buffer + 1] = '"???' .. _type .. '???"'
    end
end

local function format_as_json(obj)
    if obj == nil then return "null" else
        local buffer = {}
        format_any_value(obj, buffer)
        return table.concat(buffer)
    end
end

local function log_as_json(obj)
    myLogger:trace(format_as_json(obj))
end

return {
    allowFileFormats = { "JPEG", "TIFF", "DNG", "ORIGINAL" },
    allowColorSpaces = { "sRGB", "AdobeRGB", "ProPhotoRGB" },
    --hideSections = { "exportLocation", "postProcessing", "video", "watermarking" },
    hideSections = { "postProcessing", "video", "watermarking" },
    processRenderedPhotos = function(functionContext, exportContext)
        -- function num : 0_2 , upvalues : logger, LrPathUtils, LrApplication, LrFileUtils, LrDialogs, LrTasks
        myLogger:trace("processRenderedPhotos")
        local tempFolder = _G.TMPPATH
        local activeCatalog = LrApplication.activeCatalog()
        local exportSession = exportContext.exportSession
   log_as_json(exportContext.propertyTable)
        --special path handling for windows
        if WIN_ENV then
            tempFolder = tempFolder .. "\\"
        end
        myLogger:trace("tmp_folder = %s", tempFolder)
        local inputListFilePath = tempFolder .. _G.INPUT_FILE_LIST
        myLogger:trace("input list file = %s", inputListFilePath)
        local inputListFile = (io.open)(inputListFilePath, "wb+")

        local count = exportSession:countRenditions()
        myLogger:trace ("images to process %d", count)


        -- at least two images are required for stacking
        if count > 1  then
            myLogger:trace("creating input list for Helicon")
            local progressScope = exportContext:configureProgress({ title = LOC("$$$/HeliconFocus/Publish/Progress=Exporting ^1 photos to Helicon Focus", count) })
            local sourcePath = ""
            for i, rendition in exportContext:renditions() do
                local currentPhotoPath = (rendition.photo):getRawMetadata("path")

                if sourcePath:len() == 0 then
                    sourcePath = LrPathUtils.parent(currentPhotoPath)
                end
                myLogger:trace("Rendering %d (%s)", i, currentPhotoPath)


                local success, pathOrMessage = rendition:waitForRender()
                myLogger:trace("Rendered %d, status: %s, path  %p" , i, tostring(success), pathOrMessage)
                if success then
                    inputListFile:write(pathOrMessage .. "\n")
                else
                    myLogger:trace("failed to render %d, error: %s", i, pathOrMessage)
                    rendition:uploadFailed(pathOrMessage)
                end

            end
            inputListFile:close()
            myLogger:trace("after creating input list")


            --local outputFileName = "hf_output.txt"
            local outputFilePath = (string.format)("%s/%s", tempFolder, _G.OUTPUT_FILE_LIST)

            do
                if LrFileUtils.exists(outputFilePath) then
                    LrFileUtils.delete(outputFilePath)
                end



                do
                    if not LrFileUtils.exists(_G.HFPATH) then
                        local msg = (string.format)("Cannot find Helicon Focus at: %s", appPath);
                        LrDialogs.message("Export to Helicon Focus", msg, "info")
                    end

                    local focusCommand = (string.format) ("\"%s\" --lightroom-integration-mode -i \"%s\" -o \"%s\" --preferred-output-path \"%s\"", _G.HFPATH, inputListFilePath, outputFilePath, sourcePath)

                    if WIN_ENV then
                        focusCommand = "\"" .. focusCommand .. "\""
                    end

                    myLogger:trace((string.format)("Source path: %s", sourcePath))
                    myLogger:trace((string.format)("executing: %s", focusCommand))

                    local ret = LrTasks.execute(focusCommand)
                    myLogger:trace((string.format)("ret from exe: %d", ret))

                    if LrFileUtils.exists(outputFilePath) then
                        local f = (io.open)(outputFilePath, "rb")
                        for resultFile in f:lines() do
                            resultFile = trimr(resultFile)
                            myLogger:trace("importing %s", resultFile)
                            if LrFileUtils.exists(resultFile) then
                                activeCatalog:withWriteAccessDo("Import from Helicon Focus", function()
                                    -- function num : 0_2_0 , upvalues : activeCatalog, resultFile
                                    activeCatalog:addPhoto(resultFile)
                                end)
                            end
                        end
                    else
                        do
                            (LrDialogs.message)("Import from Helicon Focus", "Helicon Focus didn\'t return a result", "info")
                        end
                    end



                end
            end
        else
         myLogger:trace("nothing to do...")
        end

    end
}

