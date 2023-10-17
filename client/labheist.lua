-- Last Modification: 16/10/2023
local securityBypass = false
local npcSpawned = false
local labcoords1 = Config.LabHackOne
local labcoords2 = Config.LabHackTwo
local labcoords3 = Config.LabSecurityHack
local finished = false
local blips = {}
local labSecurity = {}

local heistTime = Config.LabHeistTime

local hackingTime = Config.HackingTime * 1000
local mailTime = Config.MailTime * 1000

-- This will spawn the Lab Boss
Citizen.CreateThread(function()

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
                label = Translation['labHeist'].target.startRaidLab,
                action = function()
                    startLabRaid()
                end
            },
            {
                type = "server", -- This only shows up if the user as the items in his inventory
                event = "it-smallheists:server:reciveLabPayment",
                icon = "fas fa-hand",
                label = Translation['labHeist'].target.getPayment,
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
        QBCore.Functions.Notify(Translation[#universal].notifications.notEnoughtPolice, "error") -- LANG
        return
    end
    if activeJob then
        QBCore.Functions.Notify(Translation['universal'].notifications.activeJob, "error")
        return
    end
    if not hasPhone() then
        QBCore.Functions.Notify(Translation['universal'].notifications.noPhone, "error")
        return
    end
    QBCore.Functions.TriggerCallback('it-smallheists:server:getHeistStatus', function(status)
        print(status)
        if status == 'cooldown' then
            QBCore.Functions.Notify(Translation['universal'].notifications.cooldown, "error")
            return
        elseif status == 'active' then
            QBCore.Functions.Notify(Translation['universal'].notifications.activeHeist, "error")
            return
        end
        activeJob = true
        finished = false
        cleanUpLabHeist(true)
        TriggerEvent('animations:client:EmoteCommandStart', {"crossarms"})
        TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', 'active')

        QBCore.Functions.Progressbar('pickup', Translation['labHeist'].progessBars.pickup, hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
        }, {}, {}, {}, function() -- Done

            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            QBCore.Functions.Notify(Translation['universal'].notifications.location, 'primary')
            Wait(mailTime)
            sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistStart)
            exportTarget('targetOne')
            exportTarget('securityTarget')

            SetNewWaypoint(labcoords1)

        end, function() -- Cancel
            QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error')
        end)
    end, "lab")
end

function startLabHack()
    local hasItem = hasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-smallheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('cnct-elect', Translation['labHeist'].progessBars.firewall, hackingTime, false, true, {
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
                    QBCore.Functions.Progressbar('po_usb', Translation['labHeist'].progessBars.download, hackingTime, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                    }, {}, {}, {}, function() --Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        if Config.PoliceAlertLab then
                            TriggerServerEvent('police:server:policeAlert', Translation['labHeist'].notifications.policeAlert)
                        end
                        TriggerServerEvent('it-smallheists:server:giveItem', 'lab-usb', 1)
                        if securityBypass == false then
                            QBCore.Functions.Notify(Translation['labHeist'].notifications.guads, 'error', 2000)
                            spawnLabGuards()
                        end

                        sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistHack)

                        removeTarget('targetOne')
                        exportTarget('targetTwo')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.Notify(Translation['labHeist'].notifications.hackFailed, 'error', 5000)
                    if securityBypass == false then
                        QBCore.Functions.Notify(Translation['labHeist'].notifications.guads, 'error', 2000)
                        spawnLabGuards()
                    end
                end
            end, Config.LabHackType, Config.LabHackTime, 0)

        end, function() --Cancel
            QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error', 2000)
        end)
    else
        QBCore.Functions.Notify(Translation['labHeist'].notifications.noHackingDevice, 'error', 3000)
    end
end

function startLabHack2()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
    QBCore.Functions.Progressbar('cnct_elect', Translation['labHeist'].progessBars.files, hackingTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-samples', 1)
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-files', 1)

        if securityBypass == false then
            QBCore.Functions.Notify(Translation['labHeist'].notifications.guads, 'error', 2000)
            spawnLabGuards()
        end

        Wait(mailTime)
        sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistEnd)
        cleanUpLabHeist(false)
        
    end, function()
        QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error', 2000)
    end)
end

function bypassLabGuardAlarm()
    local hasItem = hasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-miniheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('lab_sec', Translation['labHeist'].progessBars.security, hackingTime, false, true, {
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
                    QBCore.Functions.Progressbar('lab_alarms', Translation['labHeist'].progessBars.rerouting, hackingTime, false, true, {
                        disableMovement = true,
                        isableCarMovement = true,
                        disableMouse = false,
                    }, {}, {}, {}, function() -- Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify(Translation['labHeist'].notifications.disabledAlarms, 'primary', 8000)
                        securityBypass = true
                        removeTarget('securityTarget')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.Notify(Translation['labHeist'].notifications.failAlarms, 'error', 5000)
                    spawnLabGuards()
                    removeTarget('securityTarget')
                end
            end, Config.LabHackType, Config.BypassHackTime, 0)
        end, function()
            QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error', 2000)
        end)

    else
        QBCore.Functions.Notify(Translation['labHeist'].notifications.noHackingDevice, 'error', 3000)
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
                    label = Translation['labHeist'].target.hackReseach,
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.targetOne = createBlip(labcoords1, Translation['labHeist'].blips.lab, 1, 5, 0.7, 6, true)

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
                    label = Translation['labHeist'].target.samples,
                },
            },
            distance = 2.0
        })

        blips.targetTwo = createBlip(labcoords2, Translation['labHeist'].blips.research, 1, 5, 0.7, 6, true)

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
                    label = Translation['labHeist'].target.security,
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.securityTarget = createBlip(labcoords3, Translation['labHeist'].blips.security, 1, 5, 0.7, 6, true)
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
    Citizen.CreateThread(function()
        Citizen.Wait(heisTime)
        if not finished then
            QBCore.Functions.Notify(Translation['labHeist'].notifications.noTime, "error") -- LANG
            cleanUpLabHeist(false)
        end
    end)
end

function sendLog(message)
    if Config.EnableLog then
        TriggerServerEvent('it-smallheists:server:sendLog', message)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    print('[it-smallheists] Stopping Lab Heist')
    cleanUpLabHeist(true)
end)