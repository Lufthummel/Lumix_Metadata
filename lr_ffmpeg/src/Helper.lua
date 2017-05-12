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
local prefs = import 'LrPrefs'.prefsForPlugin()

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "logfile" ) -- or "logfile"



-- helper function to determine how many objects are in an array
function arraycount(a)

    local i = 0
    for _ in pairs(a) do i = i+1 end
end


function readFile(file)
    local f = io.open(file, "rb")
    local s = f:read("*all")
    f:close()
    myLogger:trace( "read Json file: " .. s  )
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

function ffmpeg(file, filename, outpath, format)

    local ffmpegparam = ""
    local extension =""

    -- local jpegparam = " -q:v 1 -qmin 1 -qmax 1 "
    local jpegparam = " -q:v 2 "
    local bmpparam = " "
    local pngparam = " "
    local tiffparam = " -compression_algo packbits -pix_fmt rgb24 "
    local tiff_extension ="%03d.tiff"
    local jpeg_extension ="%03d.jpg"
    local png_extension ="%03d.png"
    local bmp_extension ="%03d.bmp"

    -- lua kann kein switch...

    if format == 'jpeg' then
        ffmpegparam = jpegparam
        extension = jpeg_extension
    elseif format == 'tiff' then
        ffmpegparam = tiffparam
        extension = tiff_extension

    elseif format == 'png' then
        ffmpegparam = pngparam
        extension = png_extension
    else
        ffmpegparam = bmpparam
        extension = bmp_extension
    end

    local result = "-"
    local quote = "\""

    cmd = _G.FFMPEGPATH .. " -i " .. quote .. file .. quote .. ffmpegparam .. quote .. outpath  .. filename .. extension .. quote

    if WIN_ENV == true then
        cmd = quote .. cmd .. quote
    end

    myLogger:trace("FFMPEG cmd = " .. cmd)
    result = LrTasks.execute( cmd )
    myLogger:trace("FFMPEG result = " .. result)

    -- exiftool
    exiftoolPath(file, outpath)
    return result

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

