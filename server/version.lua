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
    remoteVersionFile = parseJson(responseText)
    if responseText == nil or remoteVersionFile == nil then
        print("^5======================================")
        print(' ')
        print('^8ERROR: ^0Failed to check for update.')
        print(' ')
        print("^5======================================")
        return
    end
    
    if currentVersionFile.version >= remoteVersionFile.version then
        print("^5======================================")
        print("^2[it-smallheists] - The Script is up to date!")
        print("^7Current Version: ^4" .. remoteVersionFile.version .. "^7.")
        print('^7Branch: ^4'..Config.Branch.."^7.")
        print("^5======================================")
        return
    end

    print("^5======================================")
    print('^8[it-smallheists] - New update available now!')
    print('^7Current Version: ^4'..currentVersionFile.version..'^7.')
    print('^7New Version: ^4'..remoteVersionFile.version..'^7.')
    print('^7Branch: ^4'..Config.Branch.."^7.")
    print('^7Notes: ^4' ..remoteVersionFile.message.. '^7.')
    print(' ')
    print('^4Download it now on https://github.com/'..updatePath)
    print("^5======================================")
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(5000)
        updatePath = "inseltreff-net/it-smallheists"
        PerformHttpRequest("https://raw.githubusercontent.com/"..updatePath.."/"..Config.Branch.."/version", checkResourceVersion, "GET")
    end
end)
