--local QBCore = exports['qb-core']:GetCoreObject()
local securityBypass = false
local npcSpawned = false
local labcoords1 = vector3(3536.97, 3669.4, 28.12)
local labcoords2 = vector3(3559.71, 3673.84, 28.12)
local finished = false
local blips = {targetOne = nil, targetTwo = nil, securityTarget = nil}
local labSecurity = {['wave-one'] = {}, ['wave-two'] = {}, ['wave-extra'] = {}}

local heistTime = Config.LabHeistTime

local hackingTime = Config.HackingTime * 1000
local mailTime = Config.MailTime * 1000

-- This will spawn the Lab Boss
Citizen.CreateThread(function()
    exports['qb-target']:SpawnPed({
        model = Config.LabBoss.model,
        coords = Config.LabBoss.location, 
        minusOne = true, -- Set this to true if your ped is hovering above the ground but you want it on the ground (OPTIONAL)
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = Config.LabBoss.scenario,
        target = {
            options = {
                {
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
        },
    })
end)


function startLabRaid()
    --if currentCops <= Config.PoliceRequired then
        --QBCore.Functions.Notify(Lang:t{labHeist.notifications.noCops}, "error") -- LANG
        --return
    if activeJob then
        QBCore.Functions.Notify(Translation['labHeist'].notifications.activeJob, "error")
        return
    end
    QBCore.Functions.TriggerCallback('it-smallheists:server:getHeistStatus', function(isActive)
        if not isActive then
            QBCore.Functions.TriggerCallback('it-smallheists:server:isCooldownActive', function(isOnCooldown)
                if not isOnCooldown then

                    activeJob = true
                    finished = false
                    cleanUpLabHeist(true)
                    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
                    TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', true)

                    QBCore.Functions.Progressbar('pickup', Translation['labHeist'].progessBars.pickup, hackingTime, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done

                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify(Translation['labHeist'].notifications.location, 'primary')
                        Wait(mailTime)
                        sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistStart)
                        exportTarget('targetOne')
                        exportTarget('securityTarget')

                        SetNewWaypoint(labcoords1)

                    end, function() -- Cancel
                        QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error')
                    end)
                else 
                    QBCore.Functions.Notify(Translation['labHeist'].notifications.cooldown, "error")
                end
            end, "lab")
        else 
            QBCore.Functions.Notify(Translation['labHeist'].notifications.activeHeist, "error")
        end
    end, "lab")
end

function startLabHack()
    local hasItem = QBCore.Functions.HasItem(Config.HackItem)
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
                        disableCombat = true,
                    }, {}, {}, {}, function() --Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        if Config.PoliceAlertLab then
                            TriggerServerEvent('police:server:policeAlert', Translation['labHeist'].notifications.policeAlert)
                        end
                        TriggerServerEvent('it-smallheists:server:giveItem', 'lab-usb', 1)
                        if securityBypass == false then
                            QBCore.Functions.Notify(Translation['labHeist'].notifications.guads, 'error', 2000)
                            spawnLabGuards('one')
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
                        spawnLabGuards('one')
                    end
                end
            end, Config.LabHackType, Config.LabHackTime, 0)

        end, function() --Cancel
            QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error', 2000)
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
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-samples', 1)
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-files', 1)

        if securityBypass == false then
            QBCore.Functions.Notify(Translation['labHeist'].notifications.guads, 'error', 2000)
            spawnLabGuards('two')
        end

        Wait(mailTime)
        sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistEnd)
        cleanUpLabHeist(false)
        
    end, function()
        QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error', 2000)
    end)
end

function bypassLabGuardAlarm()
    local hasItem = QBCore.Functions.HasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-miniheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('lab_sec', Translation['labHeist'].progessBars.security, hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
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
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify(Translation['labHeist'].notifications.disabledAlarms, 'primary', 8000)
                        securityBypass = true
                        removeTarget('securityTarget')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.Notify(Translation['labHeist'].notifications.failAlarms, 'error', 5000)
                    spawnLabGuards('extra')
                    removeTarget('securityTarget')
                end
            end, Config.LabHackType, Config.BypassHackTime, 0)
        end, function()
            QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error', 2000)
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
    TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', false)

    if clearPeds then
        if next(labSecurity['wave-one']) ~= nil then
            for k, v in pairs(labSecurity['wave-one']) do
                if DoesEntityExist(v) then
                    DeleteEntity(v)
                end
            end
        end
        if next(labSecurity['wave-two']) ~= nil then
            for k, v in pairs(labSecurity['wave-two']) do
                if DoesEntityExist(v) then
                    DeleteEntity(v)
                end
            end
        end
        if next(labSecurity['wave-extra']) ~= nil then
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end
end


function spawnLabGuards(waveName)

    local ped = PlayerPedId()
    local randomGun = Config.LabGuardWeapons[math.random(1, #Config.LabGuardWeapons)]
    local wave = 'wave-'..waveName

    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('labPatrol')

    for k, v in pairs(Config.LabSecurity['labpatrol']) do
        loadModel(v.model)
        labSecurity[wave][k] = CreatePed(26, GetHashKey(v.model), v.coords, v.heading, true, false)
        NetworkRegisterEntityAsNetworked(labSecurity[wave][k])
        local networkID = NetworkGetNetworkIdFromEntity(labSecurity[wave][k])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(labSecurity[wave][k], 0)
        SetPedRandomProps(labSecurity[wave][k])
        SetEntityAsMissionEntity(labSecurity[wave][k])
        SetEntityVisible(labSecurity[wave][k], true)
        SetPedRelationshipGroupHash(labSecurity[wave][k], 'labPatrol')
        SetPedAccuracy(labSecurity[wave][k], Config.LabGuardAccuracy)
        SetPedArmour(labSecurity[wave][k], 100)
        SetPedCanSwitchWeapon(labSecurity[wave][k], true)
        SetPedDropsWeaponsWhenDead(labSecurity[wave][k], false)
        SetPedFleeAttributes(labSecurity[wave][k], 0, false)
        SetPedCombatAttributes(labSecurity[wave][k], 46, true)
        SetPedCombatAttributes(labSecurity[wave][k], 5, true)
        SetPedCombatAttributes(labSecurity[wave][k], 0, true)
        GiveWeaponToPed(labSecurity[wave][k], GetHashKey(randomGun), 999, false, true)
        TaskGoToEntity(labSecurity[wave][k], ped, -1, 1.0, 10.0, 1073741824, 0)

        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(labSecurity[wave][k], 10.0, 10.0, 1)
        end
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
                    action = function()
                        startLabHack()
                    end,
                    icon = "fas fa-usb",
                    label = Translation['labHeist'].target.hackReseach,
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.targetOne = AddBlipForCoord(labcoords1.x, labcoords1.y, labcoords1.z)
        SetBlipSprite(blips.targetOne, 1)
        SetBlipDisplay(blips.targetOne, 6)
        SetBlipScale(blips.targetOne, 0.7)
        SetBlipColour(blips.targetOne, 5)
        SetBlipAsShortRange(blips.targetOne, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Translation['labHeist'].blips.lab) -- LANG
        EndTextCommandSetBlipName(blips.targetOne)

    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:AddBoxZone("hack-lab2", labcoords2, 3, 3, {
            name= "hack-lab2",
            heading= 170,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    action = function()
                        startLabHack2()
                    end,
                    icon = "fab fa-usb",
                    label = Translation['labHeist'].target.samples,
                },
            },
            distance = 2.0
        })

        blips.targetTwo = AddBlipForCoord(labcoords2.x, labcoords2.y, labcoords2.z)
        SetBlipSprite(blips.targetTwo, 1)
        SetBlipDisplay(blips.targetTwo, 6)
        SetBlipScale(blips.targetTwo, 0.7)
        SetBlipColour(blips.targetTwo, 5)
        SetBlipAsShortRange(blips.targetTwo, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Translation['labHeist'].blips.research) -- LANG
        EndTextCommandSetBlipName(blips.targetTwo)

    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:AddBoxZone("sec-target-bypass", vector3(3605.52, 3636.59, 41.34), 3, 3, {
            name= "sec-target-bypass",
            heading= 262,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
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

        blips.securityTarget = AddBlipForCoord(3605.52, 3636.59, 41.34)
        SetBlipSprite(blips.securityTarget, 1)
        SetBlipDisplay(blips.securityTarget, 6)
        SetBlipScale(blips.securityTarget, 0.7)
        SetBlipColour(blips.securityTarget, 5)
        SetBlipAsShortRange(blips.securityTarget, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Translation['labHeist'].blips.security) -- LANG
        EndTextCommandSetBlipName(blips.securityTarget)
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