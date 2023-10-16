QBCore = exports['qb-core']:GetCoreObject()
activeJob = false
currentCops = 0

-- This is the handler for the cop count, you can change this to anything you want as this is by default the qb-policejob event
RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
end)

function hasItem(item)
    return QBCore.Functions.HasItem(item)
end

function sendMail(mailSender, mailSubject, mailMessage)
    if Config.PhoneScript == 'qb' then
        TriggerServerEvent('qb-phone:server:sendNewMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage, --"Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> i will email again when i see the firewall is down!" ,
        })
    elseif Config.PhoneScript == 'qs' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage, --"Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> i will email again when i see the firewall is down!" ,
            button = {}
        })
    elseif Config.PhoneScript == 'road' then
        TriggerServerEvent('roadphone:receiveMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage, --"Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> i will email again when i see the firewall is down!" ,
            image = '/public/html/static/img/icons/app/mail.png',
            button = {}
        })
    elseif Config.PhoneScript == 'gks' then
        TriggerServerEvent('gksphone:NewMail', {sender = mailSender, image = '/html/static/img/icons/mail.png', subject = mailSubject,
        message = mailMessage, --"Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> i will email again when i see the firewall is down!" ,
        button = {}
        })
    else
        QBCore.Functions.Notify(mailMessage, "primary")
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function createBlip(coords, text, sprite, color, scale, display, shortRange)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

function removeBlip (blip)
    if blip == nil then return end
    if not DoesBlipExist(blip) then return end
    RemoveBlip(blip)
end

function checkMoney(type, amount)
QBCore.Functions.TriggerCallback('it-smallheists:server:getPlayerMoney', function(money)
    if money >= amount then
        return true
    else
        return false
    end
end, type)
end