local util = require("utils")

fuelSlots = {16}

local function checkFuel()
    if (turtle.getFuelLevel() == 0) then
        for i, slotNum in ipairs(fuelSlots) do
            util.withSlot(slotNum, function ()
                turtle.refuel(1)
            end)
        end
    end

    return true
end

turtle.forward = util.callBefore(checkFuel, turtle.forward)
turtle.back = util.callBefore(checkFuel, turtle.back)
turtle.up = util.callBefore(checkFuel, turtle.up)
turtle.down = util.callBefore(checkFuel, turtle.down)
