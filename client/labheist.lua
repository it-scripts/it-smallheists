-- Last Modification: 16/10/2023
local securityBypass = false
local npcSpawned = false
local labcoords1 = Config.LabHackOne
local labcoords2 = Config.LabHackTwo
local labcoords3 = Config.LabSecurityHack
local blips = {}
local labSecurity = {}

local heistTime = Config.LabHeistTime

local hackingTime = Config.HackingTime * 1000
local mailTime = Config.MailTime * 1000

-- This will spawn the Lab Boss
CreateThread(function()

    RequestModel(Config.LabBoss.model)
    while not HasModelLoaded(Config.LabBoss.model) do
        Wait(0)
    end
    local ped = CreatePed(0, Config.LabBoss.model, Config.LabBoss.location.x, Config.LabBoss.location.y, Config.LabBoss.location.z - 1, Config.LabBoss.location.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = 'client',
                icon = "fas fa-comment",
                label = Locales[language]['LAB_HEIST_TARGET_START_RAID_LAB'],
                action = function()
                    startLabRaid()
                end
            },
            {
                type = "server", -- This only shows up if the user as the items in his inventory
                event = "it-smallheists:server:reciveLabPayment",
                icon = "fas fa-hand",
                label = Locales[language]['LAB_HEIST_TARGET_GET_PAYMENT'],
                item = {
                    "lab-usb",
                    "lab-samples",
                    "lab-files",
                },
            },
        },
        distance = 2.5,
    })
end)

function startLabRaid()
    if currentCops < Config.PoliceRequired then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_POLICE'], 'error')
        return
    end
    if activeJob then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_ACTIVE_JOB'], 'error')
        return
    end
    if not hasPhone() then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_PHONE']:format('Handy'), 'error')
        return
    end
    QBCore.Functions.TriggerCallback('it-smallheists:server:getHeistStatus', function(status)
        print(status)
        if status == 'cooldown' then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_COOLDOWN'], 'error')
            return
        elseif status == 'active' then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_ACTIVE_HEIST'], 'error')
            return
        end
        activeJob = true
        finished = false
        cleanUpLabHeist(true)
        TriggerEvent('animations:client:EmoteCommandStart', {"crossarms"})
        TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', 'active')

        QBCore.Functions.Progressbar('pickup', Locales[language]['LAB_HEIST_PROGRESSBAR_PICKUP'], hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
        }, {}, {}, {}, function() -- Done

            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
            Wait(mailTime)
            sendMail(Locales[language]['LAB_HEIST_MAIL_SENDER'], Locales[language]['LAB_HEIST_MAIL_SUBJECT'], Locales[language]['LAB_HEIST_MAIL_MESSAGE_START'])
            exportTarget('targetOne')
            exportTarget('securityTarget')

            SetNewWaypoint(labcoords1)

        end, function() -- Cancel
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
        end)
    end, "lab")
end

function startLabHack()
    local hasItem = hasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-smallheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('cnct-elect', Locales[language]['LAB_HEIST_PROGRESSBAR_FIREWALL'], hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            exports['ps-ui']:Scrambler(function(success)
                if success then
                    Wait(100)
                    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
                    Wait(500)
                    QBCore.Functions.Progressbar('po_usb', Locales[language]['LAB_HEIST_PROGRESSBAR_DOWNLOAD'], hackingTime, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                    }, {}, {}, {}, function() --Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        if Config.PoliceAlertLab then
                            TriggerServerEvent('police:server:policeAlert', Locales[language]['LAB_HEIST_NOTIFICATION_POLICE_ALERT'])
                        end
                        TriggerServerEvent('it-smallheists:server:giveItem', 'lab-usb', 1)
                        if securityBypass == false then
                            sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
                            spawnLabGuards()
                        end

                        sendMail(Locales[language]['LAB_HEIST_MAIL_SENDER'], Locales[language]['LAB_HEIST_MAIL_SUBJECT'], Locales[language]['LAB_HEIST_MAIL_MESSAGE_HACK'])

                        removeTarget('targetOne')
                        exportTarget('targetTwo')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_HACK_FAILED'], 'error')
                    if securityBypass == false then
                        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
                        spawnLabGuards()
                    end
                end
            end, Config.LabHackType, Config.LabHackTime, 0)

        end, function() --Cancel
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
        end)
    else
        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_NO_HACKING_DEVICE'], 'error')
    end
end

function startLabHack2()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
    QBCore.Functions.Progressbar('cnct_elect', Locales[language]['LAB_HEIST_PROGRESSBAR_FILES'], hackingTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-samples', 1)
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-files', 1)

        if securityBypass == false then
            sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
            spawnLabGuards()
        end

        Wait(mailTime)
        sendMail(Locales[language]['LAB_HEIST_MAIL_SENDER'], Locales[language]['LAB_HEIST_MAIL_SUBJECT'], Locales[language]['LAB_HEIST_MAIL_MESSAGE_FINISH'])
        cleanUpLabHeist(false)
        
    end, function()
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
    end)
end

function bypassLabGuardAlarm()
    local hasItem = hasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-miniheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('lab_sec', Locales[language]['LAB_HEIST_PROGRESSBAR_SECURITY'], hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
        }, {}, {}, {}, function() --Done
            TriggerEvent('animations:client:EmoteCommandStart', {"type"})
            exports['ps-ui']:Scrambler(function(success)
                if success then
                    Wait(100)
                    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
                    Wait(500)
                    QBCore.Functions.Progressbar('lab_alarms', Locales[language]['LAB_HEIST_PROGRESSBAR_REROUTING'], hackingTime, false, true, {
                        disableMovement = true,
                        isableCarMovement = true,
                        disableMouse = false,
                    }, {}, {}, {}, function() -- Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_DISABLED_ALARMS'], 'primary')
                        securityBypass = true
                        removeTarget('securityTarget')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_FAIL_ALARMS'], 'error')
                    spawnLabGuards()
                    removeTarget('securityTarget')
                end
            end, Config.LabHackType, Config.BypassHackTime, 0)
        end, function()
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
        end)

    else
        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_NO_HACKING_DEVICE'], 'error')
    end
end


function cleanUpLabHeist(clearPeds)
    removeTarget('targetOne')
    removeTarget('targetTwo')
    removeTarget('securityTarget')

    securityBypass = false
    activeJob = false
    finished = true

    TriggerServerEvent('it-smallheists:server:heistCooldown', 'lab')
    TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', 'inactive')

    if clearPeds then
        -- Clear everyList in the labSecurity table
        for k, v in pairs(labSecurity) do
            if next(labSecurity[k]) ~= nil then
                for k, v in pairs(labSecurity[k]) do
                    if DoesEntityExist(v) then
                        DeleteEntity(v)
                    end
                end
            end
        end
    end
end


function spawnLabGuards()

    local ped = PlayerPedId()
    local randomGun = Config.LabGuardWeapons[math.random(1, #Config.LabGuardWeapons)]
    -- create uniq waveID for each wave and store it in the labSecurity table
    local waveID = math.random(1, 999999)

    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('labPatrol')

    for k, v in pairs(Config.LabSecurity['labpatrol']) do
        loadModel(v.model)
        local patrolPed = CreatePed(26, GetHashKey(v.model), v.coords, v.heading, true, false)
        NetworkRegisterEntityAsNetworked(patrolPed)
        local networkID = NetworkGetNetworkIdFromEntity(patrolPed)
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(patrolPed, 0)
        SetPedRandomProps(patrolPed)
        SetEntityAsMissionEntity(patrolPed)
        SetEntityVisible(patrolPed, true)
        SetPedRelationshipGroupHash(patrolPed, 'labPatrol')
        SetPedAccuracy(patrolPed, Config.LabGuardAccuracy)
        SetPedArmour(patrolPed, 100)
        SetPedCanSwitchWeapon(patrolPed, true)
        SetPedDropsWeaponsWhenDead(patrolPed, false)
        SetPedFleeAttributes(patrolPed, 0, false)
        SetPedCombatAttributes(patrolPed, 46, true)
        SetPedCombatAttributes(patrolPed, 5, true)
        SetPedCombatAttributes(patrolPed, 0, true)
        GiveWeaponToPed(patrolPed, GetHashKey(randomGun), 999, false, true)
        TaskGoToEntity(patrolPed, ped, -1, 1.0, 10.0, 1073741824, 0)

        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(patrolPed, 10.0, 10.0, 1)
        end
        -- Create a new list in the labSecurity table
        if labSecurity[waveID] == nil then
            labSecurity[waveID] = {}
        end
        table.insert(labSecurity[waveID], patrolPed)
    end

    SetRelationshipBetweenGroups(0, 'labPatrol', 'labPatrol')
    SetRelationshipBetweenGroups(5, 'labPatrol', 'PLAYER')
    SetRelationshipBetweenGroups(5, 'PLAYER', 'labPatrol')
end

function exportTarget(targetLocation)
    if targetLocation == 'targetOne' then
        exports['qb-target']:AddBoxZone("hack-lab1", labcoords1, 1, 1, {
            name="hack-lab1",
            heading=350,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    type = 'client',
                    action = function()
                        startLabHack()
                    end,
                    icon = "fab fa-usb",
                    label = Locales[language]['LAB_HEIST_TARGET_HACK_RESEARCH'],
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.targetOne = createBlip(labcoords1, Locales[language]['LAB_HEIST_BLIP_LAB'], 1, 5, 0.7, 6, true)

    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:AddBoxZone("hack-lab2", labcoords2, 3, 3, {
            name= "hack-lab2",
            heading= 170,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    type = 'client',
                    action = function()
                        startLabHack2()
                    end,
                    icon = "fab fa-usb",
                    label = Locales[language]['LAB_HEIST_TARGET_SAMPLES'],
                },
            },
            distance = 2.0
        })

        blips.targetTwo = createBlip(labcoords2, Locales[language]['LAB_HEIST_BLIP_RESEARCH'], 1, 5, 0.7, 6, true)

    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:AddBoxZone("sec-target-bypass", labcoords3, 3, 3, {
            name= "sec-target-bypass",
            heading= 262,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    type = 'client',
                    action = function()
                        bypassLabGuardAlarm()
                    end,
                    icon = "fas fa-shield",
                    label = Locales[language]['LAB_HEIST_TARGET_SECURITY'],
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.securityTarget = createBlip(labcoords3, Locales[language]['LAB_HEIST_BLIP_SECURITY'], 1, 5, 0.7, 6, true)
    end
end

function removeTarget(targetLocation)
    if targetLocation == 'targetOne' then
        exports['qb-target']:RemoveZone("hack-lab1")
        RemoveBlip(blips.targetOne)
        blips.targetOne = nil
    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:RemoveZone("hack-lab2")
        RemoveBlip(blips.targetTwo)
        blips.targetTwo = nil
    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:RemoveZone("sec-target-bypass")
        RemoveBlip(blips.securityTarget)
        blips.securityTarget = nil
    end
end

function startHeistTimer()
    CreateThread(function()
        Wait(heisTime)
        if not finished then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_TIME'], "error")
            cleanUpLabHeist(false)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    cleanUpLabHeist(true)
end)