--- Update/Install faultyTools. Bootstrapped by gist 923866e3158f1244f0348803eb0f00a6
--#region GUI
local title = "FaultyTools Installer"
local width,height = term.getSize()

local function printTitle()
    local line = 2
    term.setCursorPos(1, line)
    for i = 1, width, 1 do write('-') end
    term.setCursorPos((width - title:len())/2, line + 1)
    print(title)
    for i = 1, width, 1 do write('-') end
end

local function writeCenter(str)
    local nLineStart = (width - str:len())/2 - 1
    local nCenterLine = height / 2

    term.clear()
    printTitle()

    term.setCursorPos(nLineStart, nCenterLine - 1)
    for i = -1, str:len(), 1 do write('-') end
    term.setCursorPos(nLineStart, nCenterLine)
    print('|' .. str .. '|')
    term.setCursorPos(nLineStart, nCenterLine + 1)
    for i = -1, str:len(), 1 do write('-') end
end
--#endregion

local blockList = [[
@.vscode
@README.md
]]
local function isBlockList(sFile)
    if blockList:gmatch("@" .. sFile)() ~= nil then
        return true
    end
end

local function downloadFile(sFileName, sPath, sUrl)
    writeCenter("Downloading File: " .. sFileName)

    local sFullPath = sPath .. '/' .. sFileName
    
    if sPath ~= nil and not fs.isDir(sPath) then fs.makeDir(sPath) end
    local response = http.get(sUrl)
    if response == nil or response.getResponseCode() ~= 200 then
        writeCenter("Failed to download file: " .. sFullPath)
        sleep(2)
        term.clear()
        term.setCursorPos(1,1)
        error()
    end
    local file = fs.open(sFullPath, 'w')
    file.write(response.readAll())
    file.close()
    response.close()
end

-- Get Directory contents from github
local function getGithubContents(repo, tree, path)
    local response = http.get('https://api.github.com/repos/' .. repo .. '/contents/' .. path .. '/?ref=' .. tree)
    local tTypes, tNames, tDownloadUrls = {}, {}, {}
    if response and response.getResponseCode() == 200 then
        response = response.readAll()
        if response ~= nil then
            for str in response:gmatch('"type": *"(%w+)"') do table.insert(tTypes, str) end
            for str in response:gmatch('"name": *"([^\"]+)"') do table.insert(tNames, str) end
            for str in response:gmatch('"download_url": *"?([^\"]+)"?,') do
                table.insert(tDownloadUrls, str)
            end
        end
    else
        writeCenter("Error: Can't resolve URL")
        sleep(2)
        term.clear()
        term.setCursorPos(1,1)
        error()
    end
    return tTypes, tNames, tDownloadUrls
end

local function getFilesList(sRepo, sTree, sPath)
    local tFiles = {}
    local tTypes, tNames, tDownloadUrls = getGithubContents(sRepo, sTree, sPath)
    for i, type in ipairs(tTypes) do
        if isBlockList(tNames[i]) then
            -- ignore file
        elseif type == "file" then
            table.insert(tFiles, {
                name = tNames[i],
                path = sPath,
                downloadUrl = tDownloadUrls[i]
            })
        elseif type == "dir" then
            local tNestedFiles = getFilesList(sRepo, sTree, sPath .. "/" .. tNames[i])
            for _, tFile in ipairs(tNestedFiles) do
                table.insert(tFiles, tFile)
            end
        end
    end
    return tFiles
end

local function postInstall(sPath)
    local installScript = sPath .. '/install.lua'
    local destPath = sPath .. '/programs/update_faultytools.lua'
    writeCenter('Installing...')
    print('\nCopy from ' .. installScript .. ' to ' .. destPath)
    if (fs.exists(destPath)) then
        fs.delete(destPath)
    end
    fs.move(installScript, destPath)

    local sCurrPath = shell.path()
    local sProgramPath = sPath .. '/programs'
    if not sCurrPath:find(sProgramPath) then
        shell.setPath(shell.path() .. ':' .. sPath .. '/programs')
    end
end

local function main(sDldir, sRepo, sTree, sPath)
    writeCenter("Connecting to Github...")
    local files = getFilesList(sRepo, sTree, sPath)
    for _, f in ipairs(files) do
        downloadFile(f.name, sDldir .. '/' .. f.path, f.downloadUrl)
    end
    postInstall(sDldir)
    writeCenter("Install completed")
    sleep(2.5)
    term.clear()
    term.setCursorPos(1,1)
end

local function parseInput(sDldir, sRepo, sTree, sPath)
    sRepo = sRepo or "scottbot95/computercraft-tools"
    sDldir = sDldir or "/"
    sPath = sPath or ""
    sTree = sTree or "master"
    main(sDldir, sRepo, sTree, sPath)
end

if not http then
    writeCenter("You need to enable the HTTP API")
    sleep(3)
    term.clear()
    term.setCursorPos(1,1)
else
    local tArgs = {...}
    for i=1,5,1 do
        if tArgs[i] == "." then tArgs[1] = nil end
    end
    parseInput(tArgs[1], tArgs[2], tArgs[3], tArgs[4])
end
