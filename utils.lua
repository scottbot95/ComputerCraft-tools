function withSlot(slotNum, body)
    local currSlot = turtle.getSelectedSlot()
    turtle.select(slotNum)
    body()
    turtle.select(currSlot)
end

function callBefore(first, second)
    local result = first()
    if (result) then
        return second()
    end
    return result
end

function toChunk(v)
    return vector.new(
        math.floor(v.x/16),
        math.floor(v.y/16),
        math.floor(v.z/16)
    )
end