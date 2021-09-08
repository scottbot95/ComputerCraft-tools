local expect = require('cc.expect').expect

local tasks = {}
local nextId = 1

local Task = {
    status = 'suspended',
    name = nil,
    routine = nil,
    id = nil,
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

local function newTask(fn, name)
    expect(1, fn, 'function')
    local task = Task:new { 
        routine = coroutine.create(fn),
        name = name or tostring(nextId),
        id = nextId
    }
    tasks[nextId] = task
    nextId = nextId + 1
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
        for i, task in pairs(tasks) do
            if task.status == 'running' and (task._param == nil or task._param == eventData[1] or eventData[1] == 'terminate') then
                local ok, param = coroutine.resume(task.routine, table.unpack(eventData, 1, eventData.n))
                if not ok then
                    error(param, 0)
                else
                    task._param = param
                end
                if coroutine.status(task.routine) == "dead" then
                    task.status = 'dead'
                    tasks[i] = nil
                    -- TODO end if there are no running tasks?
                end
            end
        end
        eventData = table.pack(os.pullEventRaw())
    end
end

local function pauseAll()
    for _, task in pairs(tasks) do
        task.status = 'suspended'
    end
end

local function cancelTask(id)
    if tasks[id] then
        tasks[id].status = 'cancelled'
        tasks[id] = nil
    end
end

local function pauseTask(id)
    if tasks[id] then
        tasks[id].status = 'suspended'
        return true
    end
end

local function resumeTask(id)
    if tasks[id] then
        tasks[id].status = 'running'
        return true
    end
end

return {
    newTask = newTask,
    getTasks = getTasks,
    run = runTasks,
    pauseAll = pauseAll,
    cancelTask = cancelTask,
    pauseTask = pauseTask,
    resumeTask = resumeTask,
}