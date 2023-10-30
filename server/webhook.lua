local webhook = "https://discord.com/api/webhooks/*********/*******************************" -- Discord Webhook Link


RegisterNetEvent('it-smallheists:server:sendWebhook')
AddEventHandler('it-smallheists:server:sendWebhook', function(title, message, color, ping)
    local src = source
    sendWebhook(src, title, message, color, ping)
end)


function sendWebhook(source, title, message, color, ping)
    
    local steamID = 'NA'
    local license = 'NA'
    local xbl = 'NA'
    local live = 'NA'
    local discordID = 'NA'
    local fivem = 'NA'

    local nameSource = GetPlayerName(source)

    for k,v in pairs(GetPlayerIdentifiers(source)) do 
        TriggerEvent('it-smallheists:server:debugMessage', 'Identifier: '..v')')
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamIDS = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            licenseS = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordID = string.gsub(v, "discord:", "")
        elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
            fivem = v
        end
    end

    local embed = {
            ["color"] = color,
            ["author"] = {
                ["name"] = "Inseltreff Roleplay",
                ["icon_url"] = avatar,
                ["url"] = avatar,
            },
            ["fields"] = {
                {
                    ["name"] = "**Player Details: **"..nameSource,
                    ["value"] = " **Player ID: "..source.."**\n**Discord ID:** <@"..discordID.."> *("..discordID..")* \n**Steam ID:** "..steamID.."\n**License:** "..license.."\n**xbl:** "..xbl.."\n**live:** "..live.."\n**fivem:** "..fivem.."",
                    ["inline"] = false,
                },
            },
            ["title"] = title,
            ["description"] = message,
        }
    if ping then
        embed[1]["content"] = "@everyone"
    end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Inseltreff Taxi-Log", embeds = embed}), { ['Content-Type'] = 'application/json' })
end