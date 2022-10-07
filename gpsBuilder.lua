---@class scm
local scm = require("scm")
---@class Scanner
local scanner = scm:load("scanner");
---@class turtleController
local tC = scm:load("turtleController");

---@class ScanDataTable
local points = {
    { x = 2, y = 1, z = 0 },
    { x = -2, y = 1, z = 0 },
    { x = 0, y = 2, z = 2 },
    { x = 0, y = 2, z = -2 },
    { x = 0, y = 0, z = 0 }
}

-- testing

-- TODOs:
-- setup input for GPS
-- research text manipulation for codes, maybe label of the floppy?

---comment
---@param point ScanData
---@param side string
---@param suckSide function
---@param dropSide function
local function writeToDrive(point, side, suckSide, dropSide)
    local _disk = tC:findItemInInventory("computercraft:disk")
    turtle.select(_disk)
    dropSide()
    if not disk.hasData(side) then error("no disk available on side: " .. side) end
    local file = io.open("./disk/gpsfile.lua", "w+")
    if not file then
        error('./disk/gpsfile.lua not found')
    end
    local _point = point.x .. ','
    _point = _point .. point.y .. ','
    _point = _point .. point.z
    file:write('shell.run("gps","host",' .. _point .. ')')
    file:flush();
    file:close();
end

---comment
---@param side string
local function createCopyinDisc(side)
    if not disk.hasData(side) then error("no disk available") end
    local file = io.open("./disk/startup.lua", "w+")
    if not file then
        error('./disk/startup.lua not found')
    end
    file:write('fs.copy("disk/gpsfile.lua", "startup.lua")')
    file:flush();
    file:close();
end

---comment
function main()
    local path = scanner.createPath(points)
    local drive = tC:findItemInInventory("computercraft:disk_drive")
    local disk = tC:findItemInInventory("computercraft:disk")
    if not drive then
        error('No Drive Found')
    end
    if not disk then
        error('No Disk Found')
    end
    turtle.select(drive)
    turtle.place()
    turtle.select(disk)
    turtle.drop();
    createCopyinDisc("front")
    turtle.suck()
    turtle.dig()
    for index, value in ipairs(path) do
        tC:compactMove(value);
        if index > 4 then return end

        drive = tC:findItemInInventory("computercraft:disk_drive")
        if not drive then
            error('No Drive found');
        end
        turtle.select(drive)
        local tPlace, tDig, tAttach, side, tDrop, tSuck
        if index < 3 then
            tPlace = turtle.placeDown
            tDig = turtle.digDown
            tSuck = turtle.suckDown
            tDrop = turtle.dropDown
            side = "bottom"
            tAttach = function()
                tC:compactMove("u")
                turtle.placeDown()
                tC:compactMove("b")
                tC:compactMove("d")
            end
        else
            tPlace = turtle.placeUp
            tDig = turtle.digUp
            tSuck = turtle.suckUp
            tDrop = turtle.dropUp
            side = "top"
            tAttach = function()
                tC:compactMove("d")
                turtle.placeUp()
                tC:compactMove("b")
                tC:compactMove("u")
            end
        end
        tPlace();

        writeToDrive({ x = index, y = index, z = index }, side, tSuck, tDrop)
        tC:compactMove("f");
        local computer = tC:findItemInInventory("computercraft:computer_normal")
        if not computer then
            computer = tC:findItemInInventory("computercraft:computer_advanced")
            if not computer then
                error('No Computer Found')
            end
        end
        turtle.select(computer)
        tPlace();
        os.sleep(1)
        local p = peripheral.wrap(side)
        if not p then error('could not find PC on side: ' .. side) end
        p.turnOn()
        local modem = tC:findItemInInventory("computercraft:wireless_modem_advanced")
        if not modem then
            modem = tC:findItemInInventory("computercraft:wireless_modem_normal")
            if not modem then
                error('no modem found')
            end
        end
        turtle.select(modem);
        tAttach();
        tSuck()
        tDig();
    end
end

main()
