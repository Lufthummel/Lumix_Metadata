--[[----------------------------------------------------------------------------

Helper.lua
LumixMetadata.lrplugin

--------------------------------------------------------------------------------

Minaxsoft
 Copyright 2015 Dr. Holger Kremmin
 All Rights Reserved.

NOTICE:

This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

It can be used for any purpose so long as the copyright notice above,
the web-page links above, and all Author and Version informations are
maintained.

Hope it is useful.

------------------------------------------------------------------------------]]

local LrTasks = import "LrTasks"
local LrLogger = import 'LrLogger'
local LrFileUtils = import 'LrFileUtils'
local prefs = import 'LrPrefs'.prefsForPlugin()

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"



-- helper function to determine how many objects are in an array
function arraycount(a)

    local i = 0
    for _ in pairs(a) do i = i+1 end
end


function readFile(file)
    myLogger:trace( "try to read  file: " .. file  )
    local f = io.open(file, "rb")
    myLogger:trace( "open "  )
    local s = f:read("*all")
    myLogger:trace( "read "  )
    f:close()
    myLogger:trace( "reading  file: " .. s  )
    return s

end


function exiftool(file)

local execpath = "/usr/local/bin/"
local exec = "exiftool"
local param = " -j -Panasonic:all "
-- local tmpfile ="/tmp/json.tmp"
local tmpfile =_G.TMPPATH .. "json.tmp"
myLogger:trace( "tmp: " .. tmpfile )
-- local cmd = execpath .. exec .. param ..'"' .. file ..'"' .. " > " .. tmpfile
cmd = _G.EXIFTOOLPATH .. param ..'"' .. file ..'"' .. " > " .. tmpfile

myLogger:trace( "Start ExifTool: " .. cmd )
result = LrTasks.execute( cmd )
myLogger:trace( "End ExifTool " .. result  )
return readFile(tmpfile)

end

function ffprobe(file)

    local quote = "\""
    local tmpfile = _G.TMPPATH .. _G.SEP .. "ffprobe.tmp"
    --tmpfile = quote .. tmpfile .. quote
    local param = " -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 "
    local out = " > " .. tmpfile


    cmd = _G.FFPROBEPATH .. param .. file .. out
    if WIN_ENV == true then
        cmd = quote .. cmd .. quote
    end

    myLogger:trace("FFPROBE cmd = " .. cmd)
    result = LrTasks.execute( cmd )
    myLogger:trace("FFPROBE result = " .. result)

    --output = readFile(tmpfile)
    output = LrFileUtils.readFile(tmpfile)
    myLogger:trace("FFPROBE putput = " .. output)
    if output == "" then

        return 0
    else
        return 42
    end

end

function exiftoolPath(file, outpath)

    local quote = "\""
    local param = " -tagsFromFile "
    local param2 = " -overwrite_original "

    -- local cmd = execpath .. exec .. param ..'"' .. file ..'"' .. " > " .. tmpfile
    cmd = _G.EXIFTOOLPATH .. " " .. param .. quote .. file .. quote .. param2 .. quote .. outpath  .. quote

    if WIN_ENV == true then
        cmd = quote .. cmd .. quote
    end

    myLogger:trace( "Start ExifTool: " .. cmd )
    result = LrTasks.execute( cmd )
    myLogger:trace( "End ExifTool " .. result  )


end

function ffmpeg(file, filename, outpath, format, start, frame, number)

    local ffmpegparam = ""
    local extension =""

    -- local jpegparam = " -q:v 1 -qmin 1 -qmax 1 "
    local jpegparam = " -q:v 2 "
    local miniparam = " -q:v 2 -filter:v scale=1200:-1 "
    local bmpparam = " "
    local pngparam = " "
    local tiffparam = " -compression_algo packbits -pix_fmt rgb24 "
    local tiff_extension ="%04d.tiff"
    local jpeg_extension ="%04d.jpg"
    local png_extension ="%04d.png"
    local bmp_extension ="%04d.bmp"
    local startparam = ""
    local frameparam = ""
    local numberparam = ""

    myLogger:trace("in ffmpeg methode")

    -- lua kann kein switch...

    if format == 'jpeg' then
        ffmpegparam = jpegparam
        extension = jpeg_extension
    elseif format == 'mini' then
        ffmpegparam = miniparam
        extension = jpeg_extension
    elseif format == 'tiff' then
        ffmpegparam = tiffparam
        extension = tiff_extension

    elseif format == 'png' or format == 'hq' then
        ffmpegparam = pngparam
        extension = png_extension
    else
        myLogger:trace("BMP...")
        ffmpegparam = bmpparam
        extension = bmp_extension
    end

    if start == nil then
        startparam = ""
    else
        startparam = " -ss " .. start
    end

    if frame == nil then
        frameparam = ""
    else
        frameparam = " -vframes " .. frame
    end

    if number == nil then
        numberparam = " -start_number 0 "
    else
        numberparam = " -start_number " .. number .. " "
    end


    local result = "-"
    local quote = "\""


    cmd = _G.FFMPEGPATH .. startparam .. " -i " .. quote .. file .. quote .. frameparam .. ffmpegparam .. numberparam .. quote .. outpath  .. filename .. "_" .. extension .. quote
    if WIN_ENV == true then
        cmd = quote .. cmd .. quote
        myLogger:trace("(ffmpeg) -> Win = ")
    end

    myLogger:trace("(ffmpeg) -> FFMPEG cmd = " .. cmd)
    result = LrTasks.execute( cmd )
    myLogger:trace("(ffmpeg) -> FFMPEG result = " .. result)

    -- convert png to hq jpg
    if format == 'hq' then
        myLogger:trace("(ffmpeg) -> hq erkannt ")
        cmd =  quote .. _G.CONVERTERPATH .. quote .. " mogrify -format jpg -quality 100 " .. quote .. outpath .. _G.SEP .. "*.*" .. quote

        if WIN_ENV == true then
            cmd = quote .. cmd .. quote
        end


        myLogger:trace("(ffmpeg) -> Magick cmd = " .. cmd)

        result = LrTasks.execute( cmd )
        myLogger:trace("(ffmpeg) -> Magick result = " .. result)
        -- delete png

        if WIN_ENV == true then
            LrFileUtils.delete(outpath .. _G.SEP .. "*.png")
            myLogger:trace("(ffmpeg) -> deleted png")
        else
            deleteFiles(outpath, ".png")
        end


    end

    -- exiftool
    exiftoolPath(file, outpath)
    return result

end

-- no wildcard delete on mac
function deleteFiles(path, extension)
    local quote = "\""
    myLogger:trace("delete in = " .. path .. " ext = " .. extension)
    local delpath = quote .. path .. quote .. "*" .. extension
    local cmd = "rm " .. delpath
    myLogger:trace("delete command = " .. cmd )
    local result = LrTasks.execute (cmd)
    myLogger:trace("result = " .. result)


    --[[local success, reason = LrFileUtils.delete( delpath)


    if not success then
        myLogger:trace("delete command = " .. delpath )
        myLogger:trace(reason)
        myLogger:trace("ext = " .. ext )
    end


        for filePath in LrFileUtils.files( path ) do
            ext = getextension(filePath)
            myLogger:trace("ext = " .. ext )
            myLogger:trace("filepath = " .. filePath )


            if ext == extension then
                if LrFileUtils.exists(quote .. filepath .. quote) then
                    myLogger:trace( "file  existiert!!!! " .. filePath)
                end

                local success, reason = LrFileUtils.moveToTrash( quote .. filepath .. quote )
                if not success then
                    myLogger:trace("delete command = " .. filepath )
                    myLogger:trace(reason)
                    myLogger:trace("ext = " .. ext )
                end
            end

        end
        --]]
end


function SplitFilename(strFilename)
    -- Returns the Path, Filename, and Extension as 3 values
    return string.match(strFilename, "(.-)([^\\]-([^%.]+))$")
end


function findlast(s, pattern, plain)
    local curr = 0
    repeat
        local next = s:find(pattern, curr + 1, plain)
        if (next) then curr = next end
    until (not next)
    if (curr > 0) then
        return curr
    end
end

--
-- Retrieve the filename portion of a path, without any extension.
--

function getbasename(p)
    local name = getname(p)
    local i = findlast(name,".", true)
    if (i) then
        return name:sub(1, i - 1)
    else
        return name
    end
end


--
-- Retrieve the directory portion of a path, or an empty string if
-- the path does not include a directory.
--

function getdirectory(p)
    local i = findlast(p,"/", true)
    if (i) then
        if i > 1 then i = i - 1 end
        return p:sub(1, i)
    else
        return "."
    end
end


--
-- Retrieve the drive letter, if a Windows path.
--

function getdrive(p)
    local ch1 = p:sub(1,1)
    local ch2 = p:sub(2,2)
    if ch2 == ":" then
        return ch1
    end
end



--
-- Retrieve the file extension.
--

function getextension(p)
    local i = findlast(p,".", true)
    if (i) then
        return p:sub(i)
    else
        return ""
    end
end



--
-- Retrieve the filename portion of a path.
--

function getname(p)
    local i = findlast(p,"[/\\]")
    if (i) then
        return p:sub(i + 1)
    else
        return p
    end
end

