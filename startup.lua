local faultyToolsDir = settings.get("faultyTools.installDir")
if not faultyToolsDir then
    error("faultyTools not installed. Please run `gist run 923866e3158f1244f0348803eb0f00a6`")
end

package.path = package.path .. ";" .. faultyToolsDir .. '/modules/?.lua'
shell.setPath(shell.path() .. ':' .. faultyToolsDir .. '/programs')

local tasks = require('tasks')

if not fs.exists("/init.d") then
    fs.makeDir("/init.d")
end
local startupScripts = fs.list("/init.d")
table.sort(startupScripts)

for _, sPath in ipairs(startupScripts) do
    local sFullPath = '/init.d/' .. sPath
    if not fs.isDir(sFullPath) then
        tasks.newTask(
            function ()
                print("Running " .. sFullPath)
                shell.run(sFullPath)
            end,
            fs.getName(sFullPath)
        ):start()
    end
end

-- local taskNames = {}
-- for _, task in ipairs(tasks.getTasks()) do
--     table.insert(taskNames, task.name)
-- end
-- textutils.pagedPrint(textutils.serialise(taskNames))

tasks.run()
