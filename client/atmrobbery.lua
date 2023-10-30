local RecentRobbery = 0, 0, 0
-- QBCore Exports / Variables --

function UseATMDisruptor()
    if RecentRobbery == 0 or GetGameTimer() > RecentRobbery then
        debugMessage('ATM: Cops Online: '..currentCops)
        if currentCops >= Config.PoliceRequired['atm'] then
            local hasItem = hasItem(Config.ATMRequiredItem)
            if hasItem then
                QBCore.Functions.Progressbar('atm_connecting_disruptor', Locales[language]['ATM_ROBBERY_PROGRESSBAR_PLUG_IN'], Config.ATMProgressBarInteger, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                animDict = 'anim@gangops@facility@servers@',
                    anim = 'hotwire',
                    flags = 49,
                }, {}, {}, function()
                    ClearPedTasks(PlayerPedId())
                    sendDispatch(Locales[language]['ATM_HEIST_NOTIFICATION_HACK_ATM'], GetEntityCoords(PlayerPedId()))
                    RecentRobbery = GetGameTimer() + Config.HeistCooldown
                    exports['ps-ui']:Scrambler(function(success)
                        if success then
                            QBCore.Functions.Progressbar('atm_grabing_cash', Locales[language]['ATM_ROBBERY_PROGRESSBAR_GET_CASH'], Config.ATMProgressBarInteger, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                            animDict = 'oddjobs@shop_robbery@rob_till',
                                anim = 'loop',
                                flags = 17,
                            }, {}, {}, function()
                                ClearPedTasks(PlayerPedId())
                                TriggerServerEvent('it-smallheists:server:AddMoney', Config.ATMRewardMoney)
                            end)
                        else
                            sendMessage(Locales[language]['ATM_HEIST_NOTIFICATION_HACK_FAILED'], 'error')
                        end
                    end, Config.ATMScramblerHackType, 20, 0) -- Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                end)
            else
                sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_ITEM']:format(Config.ATMRequiredItem), 'error')
            end
        else
            sendMessage(Locales[language]['UNIVERSAL_NOTIFICATION_NO_POLICE'], 'error')
        end
    else
        sendMessage(Locales[language]['ATM_ROBBERY_NOTIFICATION_BREACH'], 'error')
    end
end

CreateThread(function()
    -- RFID Disruptor (SCRAMBLER HACK) --
    exports['qb-target']:AddTargetModel(Config.ATMProps,  {
        options = {
            {
            type = 'client',
            action = function()
                UseATMDisruptor()
            end,
            icon = 'fas fa-microchip',
            label = Locales[language]['ATM_ROBBERY_TARGET_HACK_ATM'],
            -- item = Config.ATMLabelItem,
            },
        },
        distance = 2.5,
    })
end)