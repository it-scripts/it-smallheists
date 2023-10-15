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

    if type == "lab" then
        heistsStatus[type] = true
        Citizen.SetTimeout(Config.HeistCooldownLab * 1000, function()
            heistsStatus[type] = 'inactive'
        end)
    elseif type == "mw" then
        heistsStatus[type] = true
        Citizen.SetTimeout(Config.HeistCooldownMW * 1000, function()
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

RegisterNetEvent('it-smallheists:server:reciveMWPayment', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local recItems = {'mw-usb'}
    local reward = Config.MWPayment

    for k, v in recItems do
        player.Functions.RemoveItem(v, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v], 'remove')

    end

    player.Functions.AddMoney(Config.MoneyType, reward, 'MW heist Payment')
 
end)

RegisterNetEvent('it-smallheists:server:sendLog', function(message)
    print('[it-smallheists] '..message)
end)