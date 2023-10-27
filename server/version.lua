--== VERSION CHECK ==--

-- pars the jason code to a table
local function parseJson(data)
    local decodedData = json.decode(data)
    return decodedData
end

local currentVersionFile = parseJson(LoadResourceFile(GetCurrentResourceName(), "version"))
local remoteVersionFile = nil
local updatePath

local function checkResourceVersion(err, responseText, headers)
    if responseText == nil then
        print(" ")
        print("^5------------ ^7IT-SMALLHEISTS ^5------------")
        print('^8 ERROR: ^0Failed to check for update.')
        print("^5--------------------------------------------")
        print(" ")
        return
    end
    remoteVersionFile = parseJson(responseText)
    if currentVersionFile.version == remoteVersionFile.version then
        print(" ")
        print("^5------------ ^7IT-SMALLHEISTS ^5------------")
        print("^2IT-SMALLHEISTS is up to date!")
        print("^3Your Version: ^2" .. currentVersionFile.version .. "^3 Remote Version: ^2" .. remoteVersionFile.version .. "^3")
        print("^5--------------------------------------------")
        print(" ")
        return
    end

    local changes = remoteVersionFile.message
    local priority = remoteVersionFile.priority

    local updateMessage = " "
    if priority == "high" then
        updateMessage = "^8A new version is available! Please update the script!"
    elseif priority == "medium" then
        updateMessage = "^1A new version is available!"
    elseif priority == "low" then
        updateMessage = "^3A new version is available!"
    end

    print(" ")
    print("^5------------ ^7IT-SMALLHEISTS ^5------------")
    print(updateMessage)
    print("^3Your Version: ^8" .. currentVersionFile.version .. "^3 Remote Version: ^2" .. remoteVersionFile.version .. "^3")
    print("^3Changes: ^2" .. remoteVersionFile.message .. "")
    print("^3Download: ^2https://github.com/" .. updatePath .. "")
    print("^5--------------------------------------------")
    print(" ")
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        updatePath = "inseltreff-net/it-smallheists"
        PerformHttpRequest("https://raw.githubusercontent.com/"..updatePath.."/development/version", checkResourceVersion, "GET")
    end
end)