local finished = false
local containers = {}

local heistTime = Config.ContainerHeistTime
local mailTime = Config.MailTime * 1000


CreateThread(function()
    exports['qb-target']:SpawnPed({
        model = Config.ContainerBoss.model,
        coords = Config.ContainerBoss.location,
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = Config.ContainerBoss.scenario,
        target = {
            options = {
                {
                    icon = 'fas fa-comment',
                    label = 'Get Tip ('..Config.ContainerFee..'$)',
                    action = function()
                        startContainerHeist()
                    end
                },
            },
            distance = 2.5
        },
    })
end)

function startContainerHeist()
    if activeJob then
        QBCore.Functions.Notify(Translation['labHeist'].notifications.activeJob, "error")
        return
    end
    QBCore.Functions.TriggerCallback('it-smallheists:server:getHeistStatus', function(status)
        local isActive = false
        if status == 'inactive' then
            isActive = false
        else
            isActive = true
        end

        if not isActive then
            local hasMoney = checkMoney('cash', Config.ContainerFee)
            if not hasMoney then
                QBCore.Functions.Notify(Translation['labHeist'].notifications.noMoney, "error")
                return
            else
                TriggerServerEvent('it-smallheists:Server:removeMoney', 'cash', Config.ContainerFee)
            end

            activeJob = true
            finished = false
            TriggerEvent('animations:client:EmoteCommandStart', {"type"})
            TriggerServerEvent('it-smallheists:server:setHeistStatus', 'container', true)

            QBCore.Functions.Progressbar('pickup', Translation['labHeist'].progessBars.pickup, hackingTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
            }, {}, {}, {}, function() -- Done

                local containerAmount = math.random(Config.MinContainer, Config.MaxContainer)

                while #containers < containerAmount do
                    local container = Config.Container[math.random(1, #Config.Container)]
                    if not table.contains(containers, container) then
                        table.insert(containers, container)
                    end
                end
                createContainerTargets()

                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                QBCore.Functions.Notify(Translation['labHeist'].notifications.location, 'primary')
                Wait(mailTime)
                sendMail(Translation['labHeist'].mail.sender, Translation['labHeist'].mail.subject, Translation['labHeist'].mail.messages.heistStart)

            end, function() -- Cancel
                QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error')
            end)
        else
            QBCore.Functions.Notify(Translation['labHeist'].notifications.onGoing, 'error')
        end
    end, 'container')
end

function openContainer(contID)
    local hasItem = hasItem(Config.ContainerItem)
    if not hasItem then
        QBCore.Functions.Notify(Translation['labHeist'].notifications.noItem, "error")
        return
    end

    local currentContainer = containers[contID]
    if currentContainer == nil then return end
    TriggerEvent('animations:client:EmoteCommandStart', {"type"})
    exports['ps-ui']:Circle(function(success)
        if success then
            QBCore.Functions.Progressbar('lab_sec', Translation['labHeist'].progessBars.security, hackingTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
            }, {}, {}, {}, function()
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                -- Get Loot
                local loot = Config.Container[contID].loot
                if loot ~= nil then
                    for k, v in pairs(loot) do
                        TriggerServerEvent('it-smallheists:server:giveItem', v, 1)
                    end
                end
                -- Remove container
                removeContainerTarget(contID)
                -- Remove item
                local breakItem = math.random(1, 100)
                if breakItem <= Config.BreakChange then
                    TriggerServerEvent('it-smallheists:server:removeItem', Config.ContainerItem, 1)
                end
                -- Check if all containers are done
                if #containers == 0 then 
                end
            end, function() -- Cancel
                QBCore.Functions.Notify(Translation['labHeist'].notifications.canceled, 'error')
            end)
        else
            TriggerServerEvent('it-smallheists:server:removeItem', Config.ContainerItem, 1)
            QBCore.Functions.Notify(Translation['labHeist'].notifications.noLoot, 'error')
            --TriggerServerEvent('it-smallheists:server:alertCops', 'container')

        end
    end, Config.ContainerNumberOfCircles, Config.ContainerMinigameTime)
end

function createContainerTargets()
    for k, v in containers do
        exports['qb-target']:AddBoxZone('container-'..k, v.location, 1, 1, {
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
                    label = Translation['labHeist'].container,
                    
                },
            },
            distance = 2.0
        })
    end
end

function removeContainerTarget(target)
    exports['qb-target']:RemoveBoxZone('container-'..target)
    containers[target] = nil
end

function removeAllContainerTargets()
    if containers ~= nil then
        for k, v in containers do
            if next(containers) ~= nil then
                exports['qb-target']:RemoveBoxZone('container-'..k)
            end
        end
    end
    containers = {}
end