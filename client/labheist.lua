local QBCore = exports['qb-core']:GetCoreObject()
local securityBypass = false
local npcSpawned = false
local labcoords1 = vector3(3536.97, 3669.4, 28.12)
local labcoords2 = vector3(3559.71, 3673.84, 28.12)
local finished = false
local blips = {targetOne = nil, targetTwo = nil, securityTarget = nil}
local labSecurity = {}

local heistTime = Config.LabHeistTime * 1000

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
            useModel = false,
            options = {
                {
                    action = startLabRaid(),
                    icon = "fas fa-comment",
                    label = "Start Lab Raid", --LANG
                },
                {
                    type = "server", -- This only shows up if the user as the items in his inventory
                    event = "it-smallheists:server:reciveLabPayment",
                    icon = "fas fa-hand",
                    label = "HandOver Research", --LANG
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


local function startLabRaid()
    if currentCops >= Config.PoliceRequired then
        QBCore.Functions.Notify("Not enought cops", "error") -- LANG
        return
    if activeJob then
        QBCore.Functions.Notify("You are already doing a heist", "error") -- LANG
        return
    end
    if not isActive then
        QBCore.Functions.TriggerCallback('it-smallheists:server:isHeistActive', function(isActive)
            if not isActive then
                QBCore.Functions.TriggerCallback('it-smallheists:server:isCooldownActive', function(isOnCooldown)
                    if not isOnCooldown then

                        activeJob = true
                        TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', true)

                        QBCore.Functions.Progressbar('pickup', 'Getting Job...', 5000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done

                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                            QBCore.Functions.Notify('You will be emailed shortly with the location', 'primary') -- LANG
                            Wait(5000)
                            SendMail('Lugo Bervich', "Bio Research...", "Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> i will email again when i see the firewall is down!")
                            exportTarget('targetOne')
                            exportTarget('securityTarget')

                            SetNewWaypoint(labcoords1)

                        end, function() -- Cancel
                            QBCore.Functions.Notify('Canceled..', 'error') -- LANG
                        end)
                    else 
                        QBCore.Functions.Notify("You are on cooldown", "error") -- LANG
                    end
                end, "lab")
            else 
                QBCore.Functions.Notify("Someone is already doing this heist", "error") -- LANG
            end
        end, "lab")
    else
        QBCore.Functions.Notify("Someone is already doing this heist", "error") -- LANG
    end
end

local function startLabHack()
    local hasItem = QBCore.Functions.HasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-miniheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('cnct-elect', "Bypass Firewall", 50000, false, true, {
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
                QBCore.Functions.Progressbar('po_usb', 'Downloading Research..', HackingTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() --Done
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    if Config.PoliceAlertLab then
                        TriggerServerEvent('police:server:policeAlert', 'Break in at Humane Labs, Laboratory 1!')
                    end
                    TriggerServerEvent('it-miniheists:server:giveItem', 'lab-usb', 1)
                    if securityBypass == false then
                        TriggerServerEvent('it-miniheists:server:gatherLabNPC') -- NOT DONE / WARUM??
                        QBCore.Functions.Notify('Guards Alerted!', 'error', 2000)
                    end

                    SendMail('Lugo Bervich', "Bio Research...", "Great you did it! now head to the Cold Room and bring me some samples of their work and any files you see!")

                    removeTarget('targetOne')
                    exportTarget('targetTwo')
                end)
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                QBCore.Functions.Notify('You failed Hacking, try again', 'error', 5000)
                if securityBypass == false then
                    TriggerServerEvent('qb-miniheists:gatherlabnpc')
                    QBCore.Functions.Notify('Guards Alerted!', 'error', 2000)
                end
            end, Config.LabHackTime, Config.LabHackType, 0)

        end, function() --Cancel
            QBCore.Functions.Notify('Canceled..', 'error', 2000)
        end)
    else
        QBCore.Functions.Notify('You dont have the hack device', 'error', 3000)
    end
end

local function startLabHack2()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
    QBCore.Functions.Progressbar('cnct_elect', 'Gabbring Samples and Files', HackingTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-samples', 1)
        TriggerServerEvent('it-miniheists:server:giveItem', 'lab-files', 1)

        if securityBypass == false then
            TriggerServerEvent('qb-miniheists:gatherlabnpc')
        end

        QBCore.Functions.Notify('You got everything, Get out of there!', 'primary', 8000)

        Wait(7500)
        SendMail('Lugo Bervich', "Bio Research...", "Now Bring the Research, Samples and Files back to me for your payment!")

        cleanUpLabHeist()
        
    end, function()
        QBCore.Functions.Notify('Canceled..', 'error', 2000)
    end)
end

local function bypassLabGuardAlarm()
    local hasItem = QBCore.Functions.HasItem(Config.HackItem)
    if hasItem then
        TriggerServerEvent('it-miniheists:server:removeItem', Config.HackItem, 1)
        TriggerEvent('animations:client:EmoteCommandStart', {"type"})
        QBCore.Functions.Progressbar('cnct_elect', 'Bypassing Security Alarms...', hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() --Done
            TriggerEvent('animations:client:EmoteCommandStart', {"type"})
            exports['ps-ui']:Scambler(function(success)
                if success then
                    Wait(100)
                    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
                    Wait(500)
                    QBCore.Functions.Progressbar('po_usb', 'Rerouting Alarm Checks..', HackingTime, false, true, {
                        disableMovement = true,
                        isableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify('You Successfully Disabled the alarm system, head on in', 'primary', 8000)
                        securityBypass = true
                        removeTarget('securityTarget')
                    end)
                else
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    QBCore.Functions.Notify('You failed to bypass security alarms, careful in there', 'error', 5000)
                    removeTarget('securityTarget')
                end
            end, Config.LabHackTime, Config.BypassHackTime, 0)
        end, function()
            QBCore.Functions.Notify('Canceled..', 'error', 2000)
        end)

    else
        QBCore.Functions.Notify('You dont have the hack device', 'error', 3000)
    end
end


local function cleanUpLabHeist()
    removeTarget('targetOne')
    removeTarget('targetTwo')
    removeTarget('securityTarget')

    securityBypass = false
    activeJob = false
    finished = true

    TriggerServerEvent('it-smallheists:server:heistCooldown', 'lab')
    TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', false)

    for k, v in pairs(labSecurity) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end

end


local function spawnLabGuards()
    local ped = PlayerPedId()
    local randomGun = Config.LabGuardWeapons[math.random(1, #Config.LabGuardWeapons)]

    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('labPatrol')

    for k, v in pairs(Config.LabSecurity['labpatrol']) do
        loadModel(v.model)
        labSecurity[k] = CreatePed(26, GetHashKey(v.model), v.coords, v.heading, true, false)
        NetworkRegisterEntityAsNetworked(labSecurity[k])
        local networkID = NetworkGetNetworkIdFromEntity(labSecurity[k])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(labSecurity[k], 0)
        SetPedRandomProps(labSecurity[k])
        SetEntityAsMissionEntity(labSecurity[k])
        SetEntityVisible(labSecurity[k], true)
        SetPedRelationshipGroupHash(labSecurity[k], 'labPatrol')
        SetPedAccuracy(labSecurity[k], Config.LabGuardAccuracy)
        SetPedArmour(labSecurity[k], 100)
        SetPedCanSwitchWeapon(labSecurity[k], true)
        SetPedDropsWeaponsWhenDead(labSecurity[k], false)
        SetPedFleeAttributes(labSecurity[k], 0, false)
        SetPedCombatAttributes(labSecurity[k], 46, true)
        SetPedCombatAttributes(labSecurity[k], 5, true)
        SetPedCombatAttributes(labSecurity[k], 1424, true)
        SetPedCombatAttributes(labSecurity[k], 0, true)
        GiveWeaponToPed(labSecurity[k], GetHashKey(randomGun), 999, false, true)
        TaskGoToEntity(labSecurity[k], ped, -1, 1.0, 10.0, 1073741824, 0)

        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(labSecurity[k], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, 'labPatrol', 'labPatrol')
    SetRelationshipBetweenGroups(5, 'labPatrol', 'PLAYER')
    SetRelationshipBetweenGroups(5, 'PLAYER', 'labPatrol')
end

local function exportTarget(targetLocation)
    if targetLocation == 'targetOne' then
        exports['qb-target']:AddBoxZone("hack-lab1", labcoords1, 1, 1, {
            name="hack-lab1",
            heading=350,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    action = startLabHack(),
                    icon = "far fa-usb",
                    label = "Hack Research Files",
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.targetOne = AddBlipForCoord(labcoords1.x, labcoords1.y, labcoords1.z)
        SetBlipSprite(blips.targetOne, 161)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(blips.targetOne, 1.0)
        SetBlipColour(blips.targetOne, 3)
        SetBlipAsShortRange(blips.targetOne, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Research Files") -- LANG
        EndTextCommandSetBlipName(blips.targetOne)

    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:AddBoxZone("hack-lab2", labcoords2, 3, 3, {
            name= "hack-lab2",
            heading= 170,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    action = startLabHack2(),
                    icon = "far fa-usb",
                    label = "Steal Samples",
                },
            },
            distance = 2.0
        })

        blips.targetTwo = AddBlipForCoord(labcoords2.x, labcoords2.y, labcoords2.z)
        SetBlipSprite(blips.targetTwo, 161)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(blips.targetTwo, 1.0)
        SetBlipColour(blips.targetTwo, 3)
        SetBlipAsShortRange(blips.targetTwo, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Research Samples") -- LANG
        EndTextCommandSetBlipName(blips.targetTwo)

    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:AddBoxZone("sec-target-bypass", vector3(3605.52, 3636.59, 41.34), 3, 3, {
            name= "sec-target-bypass",
            heading= 262,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    action = bypassLabGuardAlarm(),
                    icon = "fas fa-shield",
                    label = "Bypass Security(1 Shot)",
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.securityTarget = AddBlipForCoord(3605.52, 3636.59, 41.34)
        SetBlipSprite(blips.securityTarget, 161)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(blips.securityTarget, 1.0)
        SetBlipColour(blips.securityTarget, 3)
        SetBlipAsShortRange(blips.securityTarget, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Security Bypass") -- LANG
        EndTextCommandSetBlipName(blips.securityTarget)
    end
end

local function removeTarget()
    if targetLocation == 'targetOne' then
        exports['qb-target']:RemoveBoxZone("hack-lab1")
        RemoveBlip(blips.targetOne)
        blips.targetOne = nil
    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:RemoveBoxZone("hack-lab2")
        RemoveBlip(blips.targetTwo)
        blips.targetTwo = nil
    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:RemoveBoxZone("sec-target-bypass")
        RemoveBlip(blips.securityTarget)
        blips.securityTarget = nil
    end
end

local function startHeistTimer()
    Citizen.CreateThread(function()
        Citizen.Wait(heisTime)
        if not finished then
            QBCore.Functions.Notify("You ran out of time", "error") -- LANG
            cleanUpLabHeist()
        end
    end)
end