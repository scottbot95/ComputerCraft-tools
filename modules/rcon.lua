local expect = require('cc.expect').expect

local tReceivedMessages = {}
local tReceivedMessageTimeouts = {}
local tSenderAllowList = nil

local tCommands = {
	shell = function (tMessage)
		expect(1, tMessage, "table")
		
	end
}

local sUnknownCommand = "UNKNOWN_COMMAND"

function host()
	-- Find a modem
    local sModemSide = nil
    for _, sSide in ipairs(rs.getSides()) do
        if peripheral.getType(sSide) == "modem" and peripheral.call(sSide, "isWireless") then
            sModemSide = sSide
            break
        end
    end

    if sModemSide == nil then
        print("No wireless modems found. 1 required.")
        return
    end

	rednet.open(sModemSide)

	while true do
		sender, message = rednet.receive("rcon")
		if tSenderAllowList == nil or tSenderAllowList[sender] then
			
		end
	end
end

-- local function _host()
-- 	-- Find modem
--     local modem = peripheral.find("modem")
	
-- 	if modem == nil then
-- 		print("No modems found. 1 required")
-- 		return
-- 	end
	
-- 	-- Open a channel
-- 	print("Opening channel on modem")
-- 	modem.open(os.getComputerID())
	
-- 	while true do
-- 		local sEvent, p1, p2, p3 = os.pullEvent("rcon_message")
-- 		if sEvent == "rcon_message" then
-- 			local sReplyChannel, sCommand, message = p1, p2, p3
-- 			local fCommand = tCommands[sCommand]
-- 			if fCommand then
-- 				local response = fCommand(message)
-- 				if response then
-- 					modem.transmit(sReplyChannel, os.getComputerID(), response)
-- 				end
-- 			else
-- 				print("Unknown command " .. sCommand .. " from " .. sReplyChannel)
-- 				modem.transmit(sReplyChannel, os.getComputerID(), sUnknownCommand)
-- 			end
-- 		end
-- 	end
-- end

-- local bRunning = false
-- --- Internal function to map modem_message events into rcon_message
-- local function run()
-- 	if bRunning then
-- 		error("rcon is already running", 2)
-- 	end
-- 	bRunning = true
-- 	while bRunning do
-- 		local sEvent, p1, p2, p3, p4 = os.pullEventRaw()
-- 		if sEvent == "modem_message" then
-- 			-- Got a modem message, process it into an rcon_message
--             local sModem, nChannel, nReplyChannel, tMessage = p1, p2, p3, p4
-- 			if nChannel == os.getComputerID() and type(tMessage) == "table" and tMessage.nMessageID then
-- 				if not tReceivedMessages[tMessage.nMessageID] then
-- 					tReceivedMessages[tMessage.nMessageID] = true
-- 					tReceivedMessageTimeouts[os.startTimer(30)] = tMessage.nMessageID
-- 					os.queueEvent("rcon_message", nReplyChannel, tMessage.command, tMessage.payload)
-- 				end
-- 			end
-- 		elseif sEvent == "timer" then
-- 			-- Got a timer event, use it to clear the recieve history
-- 			local nTimer = p1
-- 			local nMessageId = tReceivedMessageTimeouts[nTimer]
-- 			if nMessageId then
-- 				tReceivedMessageTimeouts[nTimer] = nil
-- 				tReceivedMessages[nMessageId] = nil
-- 			end
-- 		end
-- 	end
-- end

-- function host()
-- 	parallel.waitForAll(run, _host)
-- end
