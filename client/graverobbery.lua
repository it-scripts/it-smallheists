-- [[ Blip Variables ]] --
CementaryLocation = {}
local blipSpawned = false

-- [[ Grave Variables ]] --
local isDigging = false

-- [[ Function for Grave Stones ]] --
local ZoneSpawned = false 
local ZoneCreated = {}

CreateThread(function()
    for k, v in pairs(Config.Graves) do
        if ZoneSpawned then
            return
        end

        for k, v in pairs(Config.Graves) do
            if not ZoneCreated[k] then
                ZoneCreated[k] = {}
            end

            ZoneCreated[k] = exports['qb-target']:AddBoxZone(v["GraveName"], v["Coords"], v["Length"], v["Width"], {
                name = v["GraveName"],
                heading = v["Heading"],
                debugPoly = Config.DebugPoly,
            }, {
                options = {
                    {
                        icon = "fa-solid fa-trowel",
                        label = Locales[language]['GRAVE_ROBERY_TARGET_DIG'],
                        action = function()
                            startDigging()
                        end,
                    },
                },
        
                distance = 1
            })

            ZoneSpawned = true
        end
    end
end)

-- [[ Events ]] -- 
RegisterNetEvent('it-smallheists:client:ResetGrave', function(OldGrave, state)
    Config.Graves[OldGrave].Looted = state
end)

function startDigging()
    if isDigging then
        sendMessage(Locales[language]['GRAVE_ROBERY_NOTIFICATION_ALREADY_DIGGING'], 'error')
        return
    end

    if not hasItem(Config.GraveItem) then
        sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_ITEM']:format(Config.GraveItem), 'error')
        return
    end

    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    TriggerEvent('animations:client:EmoteCommandStart', {"dig"})
    for k, v in pairs(Config.Graves) do
        local dist = #(GetEntityCoords(ped) - vector3(Config.Graves[k]["Coords"].x, Config.Graves[k]["Coords"].y, Config.Graves[k]["Coords"].z))
        if dist <= 2 then
            if Config.Graves[k].Looted == false then
                Config.Graves[k].Looted = true
                CurGrave = k
                QBCore.Functions.Progressbar("digging", Locales[language]['GRAVE_ROBERY_PROGRESSBAR_DIGGING'], math.random(8000, 15000), false, true, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    Diggin = true
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    TriggerServerEvent('it-smallheists:server:setGraveState', CurGrave)

                    if math.random(1, 100) <= Config.GraveRewardChance then
                        local randomItem = Config.GraveRewards[math.random(1, #Config.GraveRewards)]
                        local amount = math.random(randomItem["amount"]["min"], randomItem["amount"]["max"])

                        TriggerServerEvent('it-smallheists:server:giveItem', randomItem["item"], amount)
                    else
                        sendMessage(Locales[language]['GRAVE_ROBERY_NOTIFICATION_FAIL_LOOT'], 'error')
                    end
                    if math.random(1, 100) <= Config.GraveSpecialChance then
                        TriggerServerEvent('it-smallheists:server:giveItem', Config.GraveChanceItem, 1)
                    end

                    sendDispatch(Locales[language]['GRAVE_ROBERY_NOTIFICATION_POLICE_ALERT'], playerPos)
                end, function() -- Cancel
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_CANCELED'], 'error')
                end)
            elseif Config.Graves[k].Looted == true then
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                sendMessage(Locales[language]['GRAVE_ROBERY_NOTIFICATION_ALREADY_LOOTED'], 'error')
            end
        end
    end
end