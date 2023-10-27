QBCore = exports['qb-core']:GetCoreObject()
finished = false
activeJob = false
currentCops = 0
language = Config.Language


--[[
    Here you can find all functions that are used by all heists you can change to your own systems
    If you search for a specific function and you can't find it, it's probably in
    on of the heists client files
]]

-- Feel free to change the functions below to your own systems
RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

function hasItem(item)
    return QBCore.Functions.HasItem(item)
end

function sendMessage(message, type)
    if type == 'error' then
        QBCore.Functions.Notify(message, "error")
    elseif type == 'success' then
        QBCore.Functions.Notify(message, "success")
    else
        QBCore.Functions.Notify(message, "primary")
    end
end

function hasPhone()
    if Config.PhoneScript == 'none' then return true end
    for k, v in ipairs(Config.PhoneNames) do
        if hasItem(v) then
            return true
        end
    end
    return false
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

function createBlip(coords, text, sprite, color, scale, display, shortRange)
    debugMessage('Creating blip with text: ' .. text)
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

function startHeistTimer(heist, time)
    CreateThread(function()
        Wait(heisTime)
        if not finished then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_TIME'], "error")
            if heist == 'container' then createContainerTargets() return end
            if heist == 'lab' then createJewelleryTargets() return end
        end
    end)
end

function removeBlip (blip)
    debugMessage('Trying to remove blip: ' .. blip.text .. '')
    if blip == nil then return end
    if not DoesBlipExist(blip) then return end
    RemoveBlip(blip)
end

function debugMessage(message)
    if Config.EnableLog then
        TriggerServerEvent('it-smallheists:server:debugMessage', message)
    end
end