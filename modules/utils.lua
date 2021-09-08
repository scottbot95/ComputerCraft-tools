local function withSlot(slotNum, body)
    local currSlot = turtle.getSelectedSlot()
    turtle.select(slotNum)
    body()
    turtle.select(currSlot)
end

local function callBefore(first, second)
    local result = first()
    if (result) then
        return second()
    end
    return result
end

local function toChunk(v)
    return vector.new(
        math.floor(v.x/16),
        math.floor(v.y/16),
        math.floor(v.z/16)
    )
end

local function enum(tbl)
    local length = #tbl
    for i = 1, length do
        local v = tbl[i]
        tbl[v] = i
    end

    return tbl
end

return {withSlot = withSlot, callBefore = callBefore, toChunk = toChunk, enum = enum}