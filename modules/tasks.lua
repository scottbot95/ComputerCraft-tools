local expect = require('cc.expect').expect

local tasks = {}

local Task = {
    status = 'suspended',
    routine = nil,
    _param = nil
}

function Task:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Task:suspend()
    self.status = 'suspended'
end

function Task:start()
    self.status = 'running'
end

local function newTask(fn)
    expect(1, fn, 'function')
    local task = Task:new { routine = coroutine.create(fn) }
    table.insert(tasks, task)
    return task
end

local function getTasks()
    local copy = {}
    for k,v in pairs(tasks) do
        copy[k] = v
    end
    return copy
end

local function runTasks()
    local eventData = { n = 0 }
    while true do
        for i, task in ipairs(tasks) do
            if task.status == 'running' and (task._param == nil or task._param == eventData[1] or eventData[1] == 'terminate') then
                local ok, param = coroutine.resume(task.routine, table.unpack(eventData, 1, eventData.n))
                if not ok then
                    error(param, 0)
                else
                    task._param = param
                end
                if coroutine.status(task.routine) == "dead" then
                    task.status = 'dead'
                    table.remove(tasks, i)
                    -- TODO end if there are no running tasks?
                end
            end
        end
        eventData = table.pack(os.pullEventRaw())
    end
end

return { newTask = newTask, getTasks = getTasks, run = runTasks }