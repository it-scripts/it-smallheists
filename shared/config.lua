Config = Config or {}
Locales = Locales or {}

--[[
    The first thing will be to choose our main language, here you can choose
    between the default languages that you will find within locales/*,
    if yours is not there, feel free to create it!
]]

Config.Language = 'en'

--[[
    Here you set up the discord webhook, you can find more information about
    this in the server/webhook.lua file.
    If you dont know what a webhook is, you can read more about it here:
    https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
]]
Config.Webhook = {
    ['active'] = true, -- Set to true to enable the webhook
    ['url'] = nil, -- This will do nothing set you webhook url in server/webhook.lua
    ['name'] = 'it-smallheists', -- Name for the webhook
    ['avatar'] = 'https://i.imgur.com/KVtd6OT.png', -- Avatar for the webhook
    ['color'] = 16711680, -- Default color for the webhook
}

--[[
    Next you have to choose the phone you want to use, you can choose between:
    -- qb = qb-phone
    -- qs = quasar smartphone
    -- road = roadphone
    -- gks = gks phone
    -- none = no phone script
    You also have to add the item names of your phones to Config.PhoneNames below

    if you want to use your own phone script, you can do this by adding it to
    the client/main.lua file, you can find more information about this in the file
]]

Config.PhoneScript = 'qs'
Config.PhoneNames = { -- Add the item names of your phones here
    'phone',
    'classic_phone',
    'black_phone',
}

--[[
    Here you can set the amount of police required to start a certain heist
    and if you want to enable/disable police alert for a certain heist
]]

Config.PoliceRequired = {
    ['lab'] = 0, -- Police Required for Lab Heist
    ['container'] = 0, -- Police Required for Container Heis
}

Config.PoliceAlert = {
    ['lab'] = true, -- Set to true to enable police alert for the Lab heist
    ['container'] = true, -- Set to true to enable police alert for the Container heist
    ['grave'] = true, -- Set to true to enable police alert for the Graverobbery
}

--[[
    Here you can set the amount of time you have to complete a heist
]]

Config.HeistTime = {
    ['lab'] = 600, -- Time in seconds to complete the Lab heist
    ['container'] = 600, -- Time in seconds to complete the Container heist
}

--[[
    Here you can set the cooldown between two heists
]]

Config.HeistCooldown = {
    ['lab'] = 3600, -- Cooldown in seconds between two Lab heists
    ['container'] = 3600, -- Cooldown in seconds between two MW heists
}

--[[
    Here you can set how long it takes to get a mail from the heist
]]
Config.MailTime = {
    ['lab'] = 10, -- Time in seconds to wait for the mail to arrive
    ['container'] = 10, -- Time in seconds to wait for the mail to arrive
}

--[[
    Debug mode, you can see all kinds of prints/logs using debug,
    but it's only for development.
]]
Config.Branch = 'development' -- Set to 'master' to use the master branch, set to 'development' to use the dev branch
Config.Debug = false -- Set to true to enable debug mode
Config.DebugPoly = false -- Set to true to enable debug mode for PolyZone

--[[
    If you want to change some things in the heist, you can do this in the
    the config files of the heist, you can find them in shared/heists/*.lua
]]