local enum = require('utils').enum
local tasks = require('tasks')

local LogLevel = enum {
    "ERROR",
    "WARN",
    "INFO",
    "DEBUG",
    "VERBOSE"
}

local logLevel = LogLevel.INFO

local function setLogLevel(nLogLevel)
    logLevel = nLogLevel
end

local function logMessage(prefix, msg)
    if type(msg) == 'function' then
        msg = msg()
    end
    msg = tostring(msg)
    local taskName = tasks.getRunningTask().name
    print(('[%s] %s %s'):format(taskName, prefix, msg))
end

Logger = {}

function Logger:new(prefix)
    o = { prefix = prefix }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Logger:error(msg)
    if (logLevel < LogLevel.ERROR) then
        logMessage(self.prefix, msg)
    end
end

function Logger:warn(msg)
    if (logLevel < LogLevel.WARN) then
        logMessage(self.prefix, msg)
    end
end

function Logger:info(msg)
    if (logLevel < LogLevel.INFO) then
        logMessage(self.prefix, msg)
    end
end

function Logger:debug(msg)
    if (logLevel < LogLevel.DEBUG) then
        logMessage(self.prefix, msg)
    end
end

function Logger:verbose(msg)
    if (logLevel < LogLevel.VERBOSE) then
        logMessage(self.prefix, msg)
    end
end

return {LogLevel = LogLevel, setLogLevel = setLogLevel, Logger = Logger}