local tFilesToDelete = {
    "modules",
    "programs"
}

local sInstallDir = settings.get("faultyTools.installDir", "/")

fs.delete("/startup")
for _, sPath in ipairs(tFilesToDelete) do
    fs.delete(sInstallDir .. '/' .. sPath)
end

settings.unset('faultyTools.installDir')
