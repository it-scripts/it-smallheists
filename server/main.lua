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
        Citizen.SetTimeout(Config.HeistCooldown['container'] * 1000, function()
            heistsStatus[type] = 'inactive'
        end)
    elseif type == "lab" then
        heistsStatus[type] = 'cooldown'
        Citizen.SetTimeout(Config.HeistCooldown['lab'] * 1000, function()
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
        -- TODO: Check if player has item in inventory to prevent exploit
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

RegisterNetEvent('it-smallheists:server:giveMoney', function(type, amount, reason)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    player.Functions.AddMoney(type, amount, reason)
end)


RegisterNetEvent('it-smallheists:server:debugMessage', function(message)
    print('[DEBUG]: '..message)
end)


RegisterNetEvent('it-smallheists:server:alertCops')
AddEventHandler('it-smallheists:server:alertCops', function(coords, message)
TriggerEvent('emergencydispatch:emergencycall:new', "police", message, vector3(coords.x, coords.y, coords.z), true)
end)