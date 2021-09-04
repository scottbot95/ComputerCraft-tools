local utils = require("utils")

local up = vector.new(0, 1, 0) -- rotate clockwise in cross product
local down = vector.new(0, -1, 0) -- rotate counter-clockwise in cross product

local position
local direction = nil

local function autoInitialize()
    local startPosition = vector.new(gps.locate(2, true))
    for i = 1, 4 do
        if (turtle.forward()) then
            local newPosition = vector.new(gps.locate(2, true))
            initialize(newPosition, newPosition - startPosition)
            break
        end
        turtle.turnLeft()
    end
    error("Failed to determine forward direction")
end

local function initialize(x, y, z, facing)
    if (type(x) == "table") then
        position = x
        direction = y
    else
        position = vector.new(x,y,z)
        direction = facing
    end

    turtle.forward = utils.callBefore(turtle.forward, function()
        position = position + direction
    end)

    turtle.back = utils.callBefore(turtle.back, function()
        position = position - direction
    end)

    turtle.turnLeft = utils.callBefore(turtle.turnLeft, function()
        direction = direction:cross(down)
    end)

    turtle.turnRight = utils.callBefore(turtle.turnRight, function()
        direction = direction:cross(up)
    end)

    turtle.up = utils.callBefore(turtle.up, function ()
        position = position + up
    end)

    turtle.down = utils.callBefore(turtle.down, function ()
        position = position + down
    end)
end

return {autoInitialize = autoInitialize, initialize = initialize}