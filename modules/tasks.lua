local expect = require('cc.expect').expect

local tasks = {}
local nextId = 1
local runningTask = nil

local Task = {
    status = 'suspended',
    name = nil,
    routine = nil,
    id = nil,
    _yieldValue = nil
}

---Create a new task
---@param o table
---@return table
function Task:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---Suspend this task, preventing it from running.
---This won't pause the task immediately, but will prevent the task
---from being resumed after the next coroutine.yield() call
function Task:suspend()
    self.status = 'suspended'
end

---Queues task for execution. May be used to resume a suspended task
---CANNOT be used on a cancelled task
function Task:start()
    if self.status == 'cancelled' then
        error('Cannot start a cancelled task')
    end
    self.status = 'running'
end

---Cancel a task, removing it from the execution queue entirely
---A cancelled task cannot be resumed
function Task:cancel()
    self.status = 'cancelled'
    tasks[self.id] = nil
end

---Await completion of this task. Must be called inside a task t
function Task:await()
    if not runningTask then
        error('Must await a task inside another task')
    end
    if runningTask == self then
        error('A task cannot await itself')
    end

    while self.status ~= "dead" do
        coroutine.yield()
    end

    return self._yieldValue
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
    local bRunning = true
    while bRunning do
        for id, task in pairs(tasks) do
            if task.status == 'running' and (task._yieldValue == nil or task._yieldValue == eventData[1] or eventData[1] == 'terminate') then
                runningTask = task
                local ok, result = coroutine.resume(task.routine, table.unpack(eventData, 1, eventData.n))
                runningTask = nil -- probably not needed, but just be safe since technically no task is running at this point
                if not ok then
                    error(result, 0)
                else
                    task._yieldValue = result
                end
                if coroutine.status(task.routine) == "dead" then
                    task.status = 'dead'
                    tasks[id] = nil
                    bRunning = false
                end
            end
        end
        eventData = table.pack(os.pullEventRaw())
    end
end

local function pauseAll()
    for _, task in pairs(tasks) do
        task:suspended()
    end
end

local function cancelTask(id)
    if tasks[id] then
        tasks[id]:cancel()
    end
end

local function pauseTask(id)
    if tasks[id] then
        tasks[id]:suspend()
        return true
    end
end

local function resumeTask(id)
    if tasks[id] then
        tasks[id]:start()
        return true
    end
end

local function getRunningTask()
    return runningTask
end

return {
    newTask = newTask,
    getTasks = getTasks,
    run = runTasks,
    pauseAll = pauseAll,
    cancelTask = cancelTask,
    pauseTask = pauseTask,
    resumeTask = resumeTask,
    getRunningTask = getRunningTask,
}