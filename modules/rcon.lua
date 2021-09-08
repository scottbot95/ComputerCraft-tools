local expect = require('cc.expect')
local tasks = require('tasks')
local logger = require('log').Logger:new('rcon')

local tSenderAllowList = nil

local tCommands = {
	shell = function (tPayload)
		expect.expect(1, tPayload, "table")
		return shell.run(table.unpack(tPayload))
	end,
    cancelTask = function (nTaskID)
        tasks.cancelTask(nTaskID)
    end,
    pauseTask = function (nTaskID)
        tasks.pauseTask(nTaskID)
    end,
}

tCommands.commands = function ()
    local tCommandNames = {}
    for k, _ in pairs(tCommands) do
        table.insert(tCommandNames, k)
    end
    return tCommandNames
end

local UNKNOWN_COMMAND = "UNKNOWN_COMMAND"

local function open()
    -- Find a modem
    local sModemSide = nil
    for _, sSide in ipairs(rs.getSides()) do
        if peripheral.getType(sSide) == "modem" --[[and peripheral.call(sSide, "isWireless")]] then
            sModemSide = sSide
            break
        end
    end

    if sModemSide ~= nil then
        rednet.open(sModemSide)
        return true
    end

end

local function processCommand(message)
    local commandName = expect.field(message, 'command', 'string')
    local commandFunc = tCommands[commandName]
    if commandFunc == nil or type(commandFunc) ~= 'function' then
        logger:debug('Unknown command: ' ..commandName)
        return UNKNOWN_COMMAND
    end

    local payload = message.payload
    logger:debug('Executing ' .. commandName .. ' ' .. (payload or ''))
    return commandFunc(payload)
end

local function hostTask()
    logger:debug('Hosting rcon for ' .. os.getComputerID())
    while true do
        sender, message = rednet.receive("rcon")
        if tSenderAllowList == nil or tSenderAllowList[sender] then
            local response = processCommand(message)
            if response ~= nil then
                logger:debug('Response: ' .. tostring(response))
                rednet.send(sender, response, 'rcon')
            end
        end
    end
end

local function host()
	if not open() then
        error("No wireless modems found. 1 required.")
    end

    local task = tasks.newTask(hostTask)
    task:start()
    return task
end

local function registerCommand(sName, fHandler)
    expect.expect(1, sName, 'string')
    expect.expect(2, fHandler, 'function')
    if tCommands[sName] ~= nil then
        error(sName .. 'already registered')
    end

    tCommands[sName] = fHandler
end

local function sendCommand(id, command, payload)
    rednet.send(id, {
        command = command,
        payload = payload
    }, 'rcon')

    local _, response, _ = rednet.receive('rcon')
    return response
end

return {host = host, registerCommand = registerCommand, sendCommand = sendCommand}