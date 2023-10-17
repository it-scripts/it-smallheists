QBCore = exports['qb-core']:GetCoreObject()


-- Status:
-- active = heist is active
-- cooldown = heist is on cooldown
-- nil or inactive = heist is inactive
local heistsStatus = {}

QBCore.Functions.CreateCallback('it-smallheists:server:getHeistStatus', function(_, cb, type)
    if heistsStatus[type] ~= nil then
        cb(heistsStatus[type])
    else
        heistsStatus[type] = 'inactive'
        cb('inactive')
    end
end)

RegisterNetEvent('it-smallheists:server:setHeistStatus', function(type, status)
    heistsStatus[type] = status
end)

QBCore.Functions.CreateCallback("it-smallheists:server:isCooldownActive", function(_, cb, type)
    if heistsStatus[type] ~= nil then
        cb(heistsStatus[type])
    else
        heistsStatus[type] = false
        cb(false)
    end
end)

RegisterNetEvent('it-smallheists:server:heistCooldown', function(type)
    if type == "container" then
        heistsStatus[type] = 'cooldown'
        Citizen.SetTimeout(Config.HeistCooldownContainer * 1000, function()
            heistsStatus[type] = 'inactive'
        end)
    elseif type == "lab" then
        heistsStatus[type] = 'cooldown'
        Citizen.SetTimeout(Config.HeistCooldownLab * 1000, function()
            heistsStatus[type] = 'inactive'
        end)
    end
end)

RegisterNetEvent('it-smallheists:server:removeItem', function(item, amount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
end)

RegisterNetEvent('it-smallheists:server:giveItem', function(item, amount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)


RegisterNetEvent('it-smallheists:server:reciveLabPayment', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local recItems = {'lab-usb', 'lab-samples', 'lab-files'}
    local reward = Config.LabPayment

    for k, v in recItems do
        player.Functions.RemoveItem(v, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v], 'remove')
    end

    player.Functions.AddMoney(Config.MoneyType, reward, 'Lab heist Payment')

end)

QBCore.Functions.CreateCallback('it-smallheists:server:getPlayerMoney', function(source, cb, type)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local money = player.PlayerData.money[type]
    cb(money)
end)

RegisterNetEvent('it-smallheists:Server:removeMoney', function(type, amount, reason)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    player.Functions.RemoveMoney(type, amount, reason)
end)


RegisterNetEvent('it-smallheists:server:sendLog', function(message)
    print('[it-smallheists] '..message)
end)


RegisterNetEvent('it-smallheists:server:alertCops')
AddEventHandler('it-smallheists:server:alertCops', function(coords, message)
TriggerEvent('emergencydispatch:emergencycall:new', "police", message, vector3(coords.x, coords.y, coords.z), true)
end)

--== Update Alerts ==--
local updatePath
local resourceName

local function checkVersion(err,responseText, headers)
    local curVersion = LoadResourceFile(GetCurrentResourceName(), "version")
    if responseText == nil then print('^1['..resourceName..']^3 ERROR: ^0Failed to check for update.') return end
    if curVersion ~= nil and responseText ~= nil then
        if curVersion == responseText then Color = "^2" else Color = "^1" end
        print('\n^1----------------------------------------------------------------------------------^7')
        print('^3Latest Version is: ^2'..responseText..'!\n^7Your current version: '..Color..''..curVersion..'^7\nIf needed, update from https://github.com/'..updatePath..'')
        print('^1----------------------------------------------------------------------------------^7')
    end
end

CreateThread(function()
    updatePath = "inseltreff-net/it-smallheists"
    resourceName = GetCurrentResourceName()
    PerformHttpRequest("https://raw.githubusercontent.com/"..updatePath.."/master/version", checkVersion, "GET")
end)