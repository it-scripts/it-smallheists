Config = Config or {}
Locales = Locales or {}

--[[
    The first thing will be to choose our main language, here you can choose
    between the default languages that you will find within locales/*,
    if yours is not there, feel free to create it!
]]

Config.Language = 'en'

--[[
    Next you have to choose the phone you want to use, you can choose between:
    -- qb = qb-phone
    -- qs = quasar smartphone
    -- road = roadphone
    -- gks = gks phone
    -- none = no phone script
    You also have to add the item names of your phones to Config.PhoneNames below
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
    ['container'] = 0, -- Police Required for Container Heist
}

Config.PoliceAlert = {
    ['lab'] = true, -- Set to true to enable police alert for the Lab heist
    ['container'] = true, -- Set to true to enable police alert for the Container heist
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
Config.Debug = false -- Set to true to enable debug mode
Config.DebugPoly = false -- Set to true to enable debug mode for PolyZone

--[[
    If you want to change some things in the heist, you can do this in the
    the config files of the heist, you can find them in shared/heists/*.lua
]]