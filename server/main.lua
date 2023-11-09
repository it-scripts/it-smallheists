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
    TriggerEvent('it-smallheists:server:debugMessage', 'Giving '..amount..' '..item..' to '.. src)
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
    TriggerEvent('it-smallheists:server:debugMessage', 'Getting '..money..' '..type..' from '..src)
    cb(money)
end)

RegisterNetEvent('it-smallheists:Server:removeMoney', function(type, amount, reason)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    TriggerEvent('it-smallheists:server:debugMessage', 'Removing '..amount..' '..type..' from '..src..' for '..reason)
    player.Functions.RemoveMoney(type, amount, reason)
end)

RegisterNetEvent('it-smallheists:server:giveMoney', function(type, amount, reason)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    TriggerEvent('it-smallheists:server:debugMessage', 'Giving '..amount..' '..type..' to '..src..' for '..reason)
    player.Functions.AddMoney(type, amount, reason)
end)


RegisterNetEvent('it-smallheists:server:debugMessage', function(message)
    print('[DEBUG]: '..message)
end)


RegisterServerEvent('it-smallheists:server:setGraveState', function(CurGrave)
    local OldGrave = nil
    local src = source
    local OldGrave = CurGrave
    if Config.Graves[OldGrave].Looted == false then 
        ResetGraveTimer(OldGrave)
        TriggerClientEvent('it-smallheists:client:SetGraveState', -1, OldGrave, true)
    end
    Config.Graves[OldGrave].Looted = true
end)

function ResetGraveTimer(OldGrave)
    local num = Config.GraveTimer  -- 5 minutes 45 seconds
    local time = tonumber(num)
    SetTimeout(time, function()
        Config.Graves[OldGrave].Looted = false
        TriggerClientEvent('it-smallheists:Client:ResetGrave', -1, OldGrave, false)
    end)
end