QBCore = exports['qb-core']:GetCoreObject()
finished = false
activeJob = false
currentCops = 0
language = 'en' or Config.Language
local blips = {}

--[[
    Here you can find all functions that are used by all heists you can change to your own systems
    If you search for a specific function and you can't find it, it's probably in
    on of the heists client files
]]

-- Feel free to change the functions below to your own systems
RegisterNetEvent('police:SetCopCount', function(amount)
    currentCops = amount
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

--[[
    Here you can add your own Phone Script to the heists
    Just follow the patern below and it should work
]]

function sendMail(mailSender, mailSubject, mailMessage)
    if Config.PhoneScript == 'qb' then
        TriggerServerEvent('qb-phone:server:sendNewMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage,
        })
    elseif Config.PhoneScript == 'qs' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage,
            button = {}
        })
    elseif Config.PhoneScript == 'road' then
        TriggerServerEvent('roadphone:receiveMail', {sender = mailSender, subject = mailSubject,
            message = mailMessage,
            image = '/public/html/static/img/icons/app/mail.png',
            button = {}
        })
    elseif Config.PhoneScript == 'gks' then
        TriggerServerEvent('gksphone:NewMail', {sender = mailSender, image = '/html/static/img/icons/mail.png', subject = mailSubject,
        message = mailMessage,
        button = {}
        })
    else
        sendMessage(mailMessage, "primary")
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
    table.insert(blips, blip)
    return blip
end

function startHeistTimer(heist, time)
    CreateThread(function()
        Wait(heisTime)
        if not finished then
            finished = true
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_TIME'], "error")
            if heist == 'container' then containerCleanUp() return end
            if heist == 'lab' then cleanUpLabHeist(false) return end
        end
    end)
end

function removeBlip(blip)
    if blip == nil then return end
    if not DoesBlipExist(blip) then return end
    debugMessage('Trying to remove blip: ' .. blip .. '')
    RemoveBlip(blip)
    table_remove(blips, blip)
end

function debugMessage(message)
    if Config.EnableLog then
        TriggerServerEvent('it-smallheists:server:debugMessage', message)
    end
end

function table_contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
end

function table_remove(table, val)
    for i=1,#table do
       if table[i] == val then 
          table.remove(table, i)
       end
    end
end

function sendDispatch(message, coords)
    local _coords = vector2(coords.x, coords.y)
    TriggerEvent('emergencydispatch:emergencycall:new', "police", message, _coords, true)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    debugMessage('Stopping resource: ' .. resource)
    
    -- Clear all blips
    if #blips == 0 then return end
    if not next(blips) then return end
    for k, v in ipairs(blips) do
        removeBlip(v)
    end

    -- Clear Container Heist
    removeAllContainerTargets()

    -- Clear Lab Heist
    cleanUpLabHeist(true)

    -- Clear ATM Heist
    exports['qb-target']:RemoveTargetModel(Config.ATMProps, Locales[language]['ATM_ROBBERY_TARGET_HACK_ATM'])

end)