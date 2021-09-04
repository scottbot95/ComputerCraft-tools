--- Install this script on a disk drive named `startup`
-- Modify copy step to set desired program as startup script
-- /disk/startup will take precedence over other startup scripts on a computer

local sScriptDir = "faultyScripts"
local sStartupProgram = nil -- Set this to desired program

-- Download scripts from github
shell.run("gist", "run", "923866e3158f1244f0348803eb0f00a6")

if sStartupProgram then
    -- Copy program to startup
    fs.copy(sScriptDir .. "/" .. sStartupProgram, "startup")

    -- Start the desired program
    shell.run("startup")
end
