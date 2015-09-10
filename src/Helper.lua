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


local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "print" ) -- or "logfile"



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
    local tmpfile ="/tmp/json.tmp"

    local cmd = execpath .. exec .. param ..'"' .. file ..'"' .. " > " .. tmpfile
    myLogger:trace( "Start ExifTool: " .. cmd )
    result = LrTasks.execute( cmd )
    myLogger:trace( "End ExifTool " .. result  )
    return readFile(tmpfile)

end