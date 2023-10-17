local finished = false
local containers = {}
local containerFee = Config.ContainerFee

local policeAlert = false

local heistTime = Config.ContainerHeistTime
local mailTime = Config.MailTime * 1000


Citizen.CreateThread(function()

    --RequestAndLoadModel(Config.ContainerBoss.model)
    RequestModel(Config.ContainerBoss.model)
    while not HasModelLoaded(Config.ContainerBoss.model) do
        Wait(0)
    end
    local ped = CreatePed(0, Config.ContainerBoss.model, Config.ContainerBoss.location.x, Config.ContainerBoss.location.y, Config.ContainerBoss.location.z - 1, Config.ContainerBoss.location.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = 'client',
                label = Translation['containerHeist'].target.startHeist:format(containerFee), -- LANG
                icon = 'fas fa-comment',
                action = function()
                    startContainerHeist()
                end,
            },
        },
        distance = 2.5
    })
end)

function startContainerHeist()
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

        QBCore.Functions.TriggerCallback('it-smallheists:server:getPlayerMoney', function(money)
            local hasMoney = money >= containerFee
            if not hasMoney then
                QBCore.Functions.Notify(Translation['containerHeist'].notifications.noMoney, "error")
                return
            else
                TriggerServerEvent('it-smallheists:Server:removeMoney', 'cash', containerFee, 'Container Fee')
            end

            activeJob = true
            finished = false
            TriggerEvent('animations:client:EmoteCommandStart', {"crossarms"})
            TriggerServerEvent('it-smallheists:server:setHeistStatus', 'container', 'active')

            QBCore.Functions.Progressbar('pickup', Translation['containerHeist'].progessBars.pickup, 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
            }, {}, {}, {}, function() -- Done

                local containerAmount = math.random(Config.MinContainer, Config.MaxContainer)
                local locationString = ''

                while #containers < containerAmount do
                    local container = Config.Container[math.random(1, #Config.Container)]
                    if not table_contains(containers, container) then
                        table.insert(containers, container)
                        locationString = locationString..container.location..'<br/>'
                    end
                end
                createContainerTargets()

                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                QBCore.Functions.Notify(Translation['universal'].notifications.location, 'primary')
                Wait(mailTime)
                sendMail(Translation['containerHeist'].mail.sender, Translation['containerHeist'].mail.subject, Translation['containerHeist'].mail.messages.loactions..locationString)

            end, function() -- Cancel
                QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error')
            end)
        end, 'cash')
    end, 'container')
end

function openContainer(contID)
    local hasItem = hasItem(Config.ContainerItem)
    if not hasItem then
        QBCore.Functions.Notify(Translation['universal'].notifications.noItem:format(Config.ContainerItem), "error")
        return
    end

    local currentContainer = containers[contID]
    if currentContainer == nil then return end
    TriggerEvent('animations:client:EmoteCommandStart', {"weld"})
    exports['ps-ui']:Circle(function(success)
        if success then
            QBCore.Functions.Progressbar('loot_container', Translation['containerHeist'].progessBars.loot, 10000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
            }, {}, {}, {}, function()
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                -- Get Loot
                local loot = Config.Container[contID].loot
                if loot ~= nil then
                    for k, v in pairs(loot) do
                        local lootAmount = math.random(Config.LootAmount.min, Config.LootAmount.max)
                        TriggerServerEvent('it-smallheists:server:giveItem', v, lootAmount)
                    end
                end
                -- Remove container
                removeContainerTarget(contID)
                -- Remove item
                local breakItem = math.random(1, 100)
                if breakItem <= Config.BreakChange then
                    TriggerServerEvent('it-smallheists:server:removeItem', Config.ContainerItem, 1)
                    QBCore.Functions.Notify(Translation['containerHeist'].notifications.itemBreak, 'error')
                end
                -- Check if all containers are done
                if #containers == 0 then
                    TriggerServerEvent('it-smallheists:server:heistCooldown', 'container')
                    QBCore.Functions.Notify(Translation['containerHeist'].notifications.finished, 'success')
                    finished = true
                    activeJob = false
                end
            end, function() -- Cancel
                QBCore.Functions.Notify(Translation['universal'].notifications.canceled, 'error')
            end)
        else
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            TriggerServerEvent('it-smallheists:server:removeItem', Config.ContainerItem, 1)
            QBCore.Functions.Notify(Translation['containerHeist'].notifications.failLoot, 'error')

            if not policeAlert then
                policeAlert = true
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('it-smallheists:server:alertCops', coords, Translation['containerHeist'].policeAlert)
            end

        end
    end, Config.ContainerNumberOfCircles, Config.ContainerMinigameTime)
end

function createContainerTargets()
    for k, v in ipairs(containers) do
        exports['qb-target']:AddBoxZone('container-'..k, v.coords, 1, 1, {
            name = 'container-'..k,
            heading = 350,
            debugPoly = Config.DebugPoly,
        }, {
            options = {
                {
                    action = function()
                        openContainer(k)
                    end,
                    icon = 'fas fa-box-open',
                    label = Translation['containerHeist'].target.container,
                    
                },
            },
            distance = 2.0
        })
    end
end

function removeContainerTarget(target)
    exports['qb-target']:RemoveZone('container-'..target)
    containers[target] = nil
end

function removeAllContainerTargets()
    if containers ~= nil then
        if #containers == 0 then return end
        if not next(containers) then return end
        for k, v in ipairs(containers) do
            exports['qb-target']:RemoveZone('container-'..k)
        end
    end
    containers = {}
end

function table_contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
 end


function containerHeistTimer()
    Citizen.CreateThread(function()
        Citizen.Wait(heisTime)
        if not finished then
            QBCore.Functions.Notify(Translation['universal'].notifications.noTime, "error") -- LANG
            createContainerTargets()
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    print('[it-smallheists] Stopping Container Heist')
    removeAllContainerTargets()
end)
