-- Some essential variables
local securityBypass = false
local npcSpawned = false
local labcoords = {['hackOne'] = Config.LabHackOne, ['hackTwo'] = Config.LabHackTwo, ['security'] = Config.LabSecurityHack}
local blips = {}
local labSecurity = {}

-- Lab Heist Timings
local heistTime = Config.HeistTime['lab'] * 1000 -- From shared/config.lua
local mailTime = Config.MailTime['lab'] * 1000 -- From shared/config.lua
local hackingTime = Config.HackingTime * 1000 -- From shared/heists/lab_config.lua

-- Lab heist start
--[[
    This function is called every time the scripts starts
    It creates the ped for starting the heist
]]
CreateThread(function()

    -- Create the ped
    RequestModel(Config.LabBoss.model)
    while not HasModelLoaded(Config.LabBoss.model) do
        Wait(0)
    end
    local ped = CreatePed(0, Config.LabBoss.model, Config.LabBoss.location.x, Config.LabBoss.location.y, Config.LabBoss.location.z - 1, Config.LabBoss.location.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Add the ped to the target list
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = 'client',
                icon = "fas fa-comment",
                label = Locales[language]['LAB_HEIST_TARGET_START_RAID_LAB'],
                action = function()
                    startLabHeist()
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
    debugMessage('Lab Boss Ped Created')
end)

-- Lab heist start
--[[
    This function is called when the player interacts with the ped
    It starts the heist
]]
function startLabHeist()
    -- Check if there are enough cops online
    debugMessage('Cops Online: '..currentCops)
    if currentCops < Config.PoliceRequired['lab'] then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_POLICE'], 'error')
        return
    end

    -- Check if the player has an activeJob already
    debugMessage('Active Job: src'..PlayerId()..' Status:'..tostring(activeJob))
    if activeJob then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_ACTIVE_JOB'], 'error')
        return
    end

    -- Check if player has a phone
    debugMessage('Has Phone: src' ..GetPlayerServerId(source)..' Phone:'..tostring(hasPhone()))
    if not hasPhone() then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_ITEM']:format('Handy'), 'error')
        return
    end

    -- Trigger Callback to get the heist status
    QBCore.Functions.TriggerCallback('it-smallheists:server:getHeistStatus', function(status)
        debugMessage('Lab Heist Status: '..status)
        if status == 'cooldown' then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_COOLDOWN'], 'error')
            return
        elseif status == 'active' then
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_ACTIVE_HEIST'], 'error')
            return
        end

        -- Change the heist status of the player
        activeJob = true
        finished = false
        
        -- Cleanup the heist from the last player
        cleanUpLabHeist(true) -- True to delete the dead bodys

        -- Change the heist global status
        TriggerServerEvent('it-smallheists:server:setHeistStatus', 'lab', 'active')
        
        -- Get the job
        TriggerEvent('animations:client:EmoteCommandStart', {"crossarms"})
        QBCore.Functions.Progressbar('pickup', Locales[language]['LAB_HEIST_PROGRESSBAR_PICKUP'], hackingTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
        }, {}, {}, {}, function() -- Done

            TriggerServerEvent('it-smallheists:server:sendWebhook', 'Lab Heist', 'Player: '..GetPlayerName(PlayerId())..' ('..PlayerId()..') started a lab heist', 16711680, false)

            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_LOCATION'], 'primary')
            Wait(mailTime)
            sendMail(Locales[language]['LAB_HEIST_MAIL_SENDER'], Locales[language]['LAB_HEIST_MAIL_SUBJECT'], Locales[language]['LAB_HEIST_MAIL_MESSAGE_START'])
            exportTarget('targetOne')
            exportTarget('securityTarget')
            startHeistTimer('lab', heistTime)
            SetNewWaypoint(labcoords['hackOne'].x, labcoords['hackOne'].y)

        end, function() -- Cancel
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
        end)
    end, 'lab')
end

-- Lab heist hacks
--[[
    This function is called when the player interacts with the first hack
    It starts the first hack
]]

function labComputerHack()
    local hasItem = hasItem(Config.HackItem)
    debugMessage('Has Item: src'..PlayerId()..' Item:'..tostring(hasItem))
    if not hasItem then
        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_NO_HACKING_DEVICE'], 'error')
        return
    end

    -- Remove the item from the players inventory
    TriggerServerEvent('it-smallheists:server:removeItem', Config.HackItem, 1)

    -- Start the hack
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

                    TriggerServerEvent('it-smallheists:server:sendWebhook', 'Lab Heist', 'Player: '..GetPlayerName(PlayerId())..' ('..PlayerId()..') hacked the lab', 16711680, false)

                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})

                    if Config.PoliceAlertLab then
                        TriggerServerEvent('police:server:policeAlert', Locales[language]['LAB_HEIST_NOTIFICATION_POLICE_ALERT'])
                    end

                    TriggerServerEvent('it-smallheists:server:giveItem', 'lab-usb', 1)
                    
                    if securityBypass == false then
                        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
                        spawnLabGuards('hacking')
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
                    spawnLabGuards('hacking')
                end
            end
        end, Config.LabHackType, Config.LabHackTime, 0)

    end, function() --Cancel
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
    end)
end

function getLabFiles()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
    QBCore.Functions.Progressbar('cnct_elect', Locales[language]['LAB_HEIST_PROGRESSBAR_FILES'], hackingTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
    }, {}, {}, {}, function()

        TriggerServerEvent('it-smallheists:server:sendWebhook', 'Lab Heist', 'Player: '..GetPlayerName(PlayerId())..' ('..PlayerId()..') got the lab files', 16711680, false)

        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('it-smallheists:server:giveItem', 'lab-samples', 1)
        TriggerServerEvent('it-smallheists:server:giveItem', 'lab-files', 1)

        if securityBypass == false then
            sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_GUARDS'], 'error')
            spawnLabGuards('resarch')
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
    debugMessage('Has Item: src'..PlayerId()..' Item:'..tostring(hasItem))
    if not hasItem then
        sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_NO_HACKING_DEVICE'], 'error')
        return
    end

    -- Remove the item from the players inventory
    TriggerServerEvent('it-smallheists:server:removeItem', Config.HackItem, 1)
    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
    QBCore.Functions.Progressbar('lab_sec', Locales[language]['LAB_HEIST_PROGRESSBAR_SECURITY'], hackingTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
    }, {}, {}, {}, function() --Done
        exports['ps-ui']:Scrambler(function(success)
            if success then
                QBCore.Functions.Progressbar('lab_alarms', Locales[language]['LAB_HEIST_PROGRESSBAR_REROUTING'], hackingTime, false, true, {
                    disableMovement = true,
                    isableCarMovement = true,
                    disableMouse = false,
                }, {}, {}, {}, function() -- Done

                    TriggerServerEvent('it-smallheists:server:sendWebhook', 'Lab Heist', 'Player: '..GetPlayerName(PlayerId())..' ('..PlayerId()..') bypassed the lab security', 16711680, false)

                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_DISABLED_ALARMS'], 'primary')
                    securityBypass = true
                    removeTarget('securityTarget')
                end)
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                sendMessage(Locales[language]['LAB_HEIST_NOTIFICATION_FAIL_ALARMS'], 'error')
                spawnLabGuards('resarch')
                removeTarget('securityTarget')
            end
        end, Config.LabHackType, Config.BypassHackTime, 0)
    end, function()
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
    end)
end

-- Lab heist utils functions
--[[
    This function is called when the heist is finished or canceled
    It cleans up the heist
]]
function cleanUpLabHeist(clearPeds)
    removeTarget('targetOne')
    removeTarget('targetTwo')
    removeTarget('securityTarget')

    securityBypass = false
    activeJob = false
    finished = true

    TriggerServerEvent('it-smallheists:server:heistCooldown', 'lab')

    if clearPeds then
        -- Clear everyList in the labSecurity table
        for k, v in pairs(labSecurity) do
            if next(labSecurity[k]) ~= nil then
                for k, v in pairs(labSecurity[k]) do
                    if DoesEntityExist(v) then
                        DeleteEntity(v)
                    end
                    ClearPedEnvDirt(v)
                end
            end
        end
    end
end

--[[
    This function creates the Target Locations for the heist
    It also creates the blips for the targets
]]
function exportTarget(targetLocation)
    if targetLocation == 'targetOne' then
        exports['qb-target']:AddBoxZone("hack-lab1", labcoords['hackOne'], 1, 1, {
            name="hack-lab1",
            heading=350,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    type = 'client',
                    action = function()
                        labComputerHack()
                    end,
                    icon = "fab fa-usb",
                    label = Locales[language]['LAB_HEIST_TARGET_HACK_RESEARCH'],
                    -- item = Config.HackItem,
                },
            },
            distance = 2.0
        })

        blips.targetOne = createBlip(labcoords['hackOne'], Locales[language]['LAB_HEIST_BLIP_LAB'], 1, 5, 0.7, 6, true)

    elseif targetLocation == 'targetTwo' then
        exports['qb-target']:AddBoxZone("hack-lab2", labcoords['hackTwo'], 3, 3, {
            name= "hack-lab2",
            heading= 170,
            debugpoly = Config.DebugPoly,
        }, {
            options = {
                {
                    type = 'client',
                    action = function()
                        getLabFiles()
                    end,
                    icon = "fab fa-usb",
                    label = Locales[language]['LAB_HEIST_TARGET_SAMPLES'],
                },
            },
            distance = 2.0
        })

        blips.targetTwo = createBlip(labcoords['hackTwo'], Locales[language]['LAB_HEIST_BLIP_RESEARCH'], 1, 5, 0.7, 6, true)

    elseif targetLocation == 'securityTarget' then
        exports['qb-target']:AddBoxZone("sec-target-bypass", labcoords['security'], 3, 3, {
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

        blips.securityTarget = createBlip(labcoords['security'], Locales[language]['LAB_HEIST_BLIP_SECURITY'], 1, 5, 0.7, 6, true)
    end
end

--[[
    This function removes the Target Locations for the heist
    It also removes the blips for the targets
]]
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

--[[
    This function spawns the guards for the heist
]]
function spawnLabGuards(waveName)

    local ped = PlayerPedId()
    local randomGun = Config.LabGuardWeapons[math.random(1, #Config.LabGuardWeapons)]
    -- create uniq waveID for each wave and store it in the labSecurity table
    local waveID = math.random(1, 999999)
    while table_contains(labSecurity, waveID) do
        waveID = math.random(1, 999999)                     
    end

    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('labPatrol')

    for k, v in pairs(Config.LabSecurity[waveName]) do

        RequestModel(v.model)
        while not HasModelLoaded(v.model) do
            Wait(0)
        end

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

    debugMessage('Lab Guard Spawned waveID: '..waveID..' Amount: '..#labSecurity[waveID])

    TriggerServerEvent('it-smallheists:server:sendWebhook', 'Lab Heist', 'Player: '..GetPlayerName(PlayerId())..' ('..PlayerId()..') spawned a new wave of lab guards.\nWave infomrationen:\nWaveID: '..waveID..'\nGuard Amount: '..#labSecurity[waveID], 16711680, false)

    SetRelationshipBetweenGroups(0, 'labPatrol', 'labPatrol')
    SetRelationshipBetweenGroups(5, 'labPatrol', 'PLAYER')
    SetRelationshipBetweenGroups(5, 'PLAYER', 'labPatrol')
end