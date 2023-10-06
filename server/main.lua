QBCore = exports['qb-core']:GetCoreObject()
labActive = false
mwActive = false
labCooldown = false
mwCooldown = false

QBCore.Functions.CreateCallback('it-smallheists:server:getHeistStatus', function(_, cb, type)
    if type == "lab" then
        cb(labActive)
    elseif type == "mw" then
        cb(mwActive)
    end
end)

RegisterNetEvent('it-smallheists:server:setHeistStatus', function(type, status)
    if type == "lab" then
        labActive = status
    elseif type == "mw" then
        mwActive = status
    end
end)

QBCore.Functions.CreateCallback("it-smallheists:server:isCooldownActive", function(_, cb, type)
    if type == "lab" then
        cb(labCooldown)
    elseif type == "mw" then
        cb(mwCooldown)
    end
end)

RegisterNetEvent('it-smallheists:server:heistCooldown', function(type)
    if type == "lab" then
        labCooldown = true
        Citizen.SetTimeout(Config.HeistCooldownLab * 1000, function()
            labCooldown = false
        end)
    elseif type == "mw" then
        mwCooldown = true
        Citizen.SetTimeout(Config.HeistCooldownMW * 1000, function()
            mwCooldown = false
        end)
    end
end)

RegisterNetEvent('it-smallheists:server:removeItem', function(item, amount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    QBCore.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
end)

RegisterNetEvent('it-smallheists:server:giveItem', function(item, amount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    QBCore.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)


RegisterNetEvent('it-smallheists:server:reciveLabPayment', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local recItems = {'lab-usb', 'lab-samples', 'lab-files'}
    local reward = Config.LabPayment

    for k, v in recItems do
        Player.Functions.RemoveItem(v, 1)
    end

    Player.Functions.AddMoney(Config.MoneyType, reward, 'Lab heist Payment')

end)

RegisterNetEvent('it-smallheists:server:reciveMWPayment', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local recItems = {'mw-usb'}
    local reward = Config.MWPayment

    for k, v in recItems do
        Player.Functions.RemoveItem(v, 1)
    end

    Player.Functions.AddMoney(Config.MoneyType, reward, 'MW heist Payment')
 
end)

RegisterNetEvent('it-smallheists:server:sendLog', function(message)

    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    print('[it-smallheists] '..message)
end)