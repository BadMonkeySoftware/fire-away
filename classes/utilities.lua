-- 
-- Import

--
-- Create class, set variables

local system        = require('system')
local utilities = {}

function utilities:printTable( t )
 
    local printTable_cache = {}
 
    local function sub_printTable( t, indent )
 
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
 
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

function utilities:fileExits(fileName)
    -- Get path for file "data.txt" in the application support directory
    -- local filename = "levels/level1.lua"
    local path = system.pathForFile( fileName, system.ResourceDirectory )
    local fh, reason
    -- Open the file from the path
    if path then
        fh, reason = io.open( path, "r" )
    end
    
    if fh then
        -- File exists; read its contents into a string
        local contents = fh:read( "*a" )
        -- print( "Contents of " .. path .. "\n" .. contents )
        -- print("File Exists: " .. filename)
        io.close(fh)
        return true        
    else
        -- File open failed; output the reason
        -- print( "File open failed: " .. reason )
        return false
    end
end
function utilities:firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
function utilities:hex2rgb(origHex, alpha)
    local hex = origHex:gsub("#","")
    if hex:len() == 3 then
        return {(tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255}
    elseif hex:len() == 8 then
        return {tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255, tonumber("0x"..hex:sub(7,8))/255}
    else
        return {tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255, alpha or 1}
    end
end

-- 
-- Return
return utilities