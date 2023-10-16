Config = {}

--=== PHONE SETTINGS ===--
Config.PhoneScript = 'qs'
-- qb = qb-phone
-- qs = quasar smartphone
-- road = roadphone
-- gks = gks phone

--=== DEBUG SETTINGS ===--
Config.Debug = false -- Set to true to enable debug mode
Config.DebugPoly = true -- Set to true to enable debug mode for PolyZone

--=== POLICE SETTINGS ===--
Config.PoliceRequired = 0 -- Amount of police required to start the heist
Config.PoliceAlertLab = true -- Set to true to enable police alert for the Lab heist
Config.PoliceAlertContainer = true -- Set to true to enable police alert for the Container heist

--=== GENERAL HEIST SETTINGS ===--
Config.HeistCooldownLab = 3600 -- Cooldown in seconds between two Lab heists
Config.HeistCooldownContainer = 3600 -- Cooldown in seconds between two MW heists

Config.MoneyType = 'cash' -- cash/bank/black_money - Type of money you get from the heist
Config.MailTime = 10 -- Time in seconds to wait for the mail to arrive

--=== HACKING SETTINGS ===--
Config.HackItem = 'electronickit' -- Item required to start the hacking
Config.HackingTime = 20 -- Time in seconds for hacking progressbars / Time bevore the MiniGame starts

Config.LabHackType = 'numeric' -- can be alphabet, numeric, alphanumeric, greek, braille, runes
Config.LabHackTime = 60 -- Time in seconds to hack the Lab door
Config.BypassHackTime = 60 -- minigame timer for 1 shot to bypass security at secret location to stop guards from spawning inside lab

--=== LAB RAID STUFF ===--

Config.LabHeistTime = 600 -- Time in seconds to complete the heist

Config.LabBoss = { -- Ped for starting the Lab heist you can change every setting for the ped
    model = 's_m_y_westsec_01',
    location = vector4(2363.2644, 2520.1455, 46.6677, 325.7810),
    scenario = 'WORLD_HUMAN_GUARD_STAND',
}

Config.LabPayment = math.random(100000, 200000) -- Amount of money you get from the heist set this to 0 to disable money reward

Config.LabRewardAmount = math.random(2, 3) -- Amount of items you get from the heist set this to 0 to disable item reward
Config.LabRewards = {
    'weapon_pistol',
    'weapon_pistol_mk2',
}

Config.LabHackOne = vector3(3536.97, 3669.4, 28.12) -- Location of the first Lab hack
Config.LabHackTwo = vector3(3559.71, 3673.84, 28.12) -- Location of the second Lab hack
Config.LabSecurityHack = vector3(3593.82, 3712.27, 29.69) -- Location of the Lab security hack

--== LAB GUARD SETTINGS ==--
Config.LabGuardAccuracy = 75 -- out of 100 how accurate the guards are (100 = 100%)
Config.LabGuardWeapons = { -- this must be the weapon hash not just the weapon item name --this randomises between different guns everytime the guards are spawned
    'WEAPON_PISTOL',
    'WEAPON_COMBATPDW',
}

Config.LabSecurity = { -- The security system for the Lab
    ['labpatrol'] = {
        { coords = vector3(3532.46, 3649.46, 27.52), heading = 63.5, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3537.36, 3645.83, 28.13), heading = 46.35, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3546.64, 3642.28, 28.12), heading = 96.74, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3550.22, 3654.24, 28.12), heading = 156.29, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3554.83, 3661.73, 28.12), heading = 21.64, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3557.54, 3674.59, 28.12), heading = 104.25, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3564.64, 3682.23, 28.12), heading = 48.35, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3594.74, 3686.06, 27.62), heading = 124.5, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3593.82, 3712.27, 29.69), heading = 139.73, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3608.93, 3729.39, 29.69), heading = 323.56, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3618.91, 3722.51, 29.69), heading = 85.71, model = 's_m_m_fiboffice_02'},
        { coords = vector3(3596.07, 3703.44, 29.69), heading = 344.89, model = 's_m_m_fiboffice_02'},
    },
}


--=== CONTAINER RAID STUFF ===--

Config.ContainerHeistTime = 600 -- Time in seconds to complete the heist
Config.ContainerBoss = {
    model = 's_m_y_westsec_01',
    location = vector4(2363.2644, 2520.1455, 46.6677, 325.7810),
    scenario = 'WORLD_HUMAN_GUARD_STAND',
}

Config.ContainerItem = 'electronickit' -- Item required to open a container
Config.BreakChange = 50 -- Chance in % to break the item while opening a container

Config.ContainerFee = math.random(100000, 200000) -- Amount of money you have to pay to get container locations

Config.MinContainer = 1 -- Minimum amount of containers to break
Config.MaxContainer = 3 -- Maximum amount of containers to break


--== CONTAINER MINIGAME SETTINGS ==--
Config.ContainerMinigameTime = 20 -- Time in seconds for the minigame
Config.ContainerNumberOfCircles = 3 -- Number of circles in the minigame


--== CONTAINER == --
Config.Container = {
    [1] = {coords = vector3(896.4028, -3023.6819, 5.9020), location = 'D5 West/2', loot = {'electronickit'}},
    [2] = {coords = vector3(896.4840, -3026.3210, 5.9020), location = 'D5 West/3', loot = {'electronickit'}},
    [3] = {coords = vector3(896.4805, -3028.9470, 5.9020), location = 'D5 West/4', loot = {'electronickit'}},
    [4] = {coords = vector3(896.4009, -3031.4707, 5.9020), location = 'D5 West/5', loot = {'electronickit'}},

    [5] = {coords = vector3(896.3021, -3047.4612, 5.9020), location = 'D1 East/1', loot = {'electronickit'}},

    [6] = {coords = vector3(965.0945, -3047.4458, 5.9020), location = 'D5 East/1', loot = {'electronickit'}},
    [7] = {coords = vector3(965.0499, -3044.8245, 5.9020), location = 'D5 East/2', loot = {'electronickit'}},
    [8] = {coords = vector3(965.1483, -3042.2615, 5.9020), location = 'D5 East/3', loot = {'electronickit'}},
    [9] = {coords = vector3(965.1497, -3039.2942, 5.9020), location = 'D5 East/4', loot = {'electronickit'}},
    [10] = {coords = vector3(965.2185, -3037.0554, 5.9020), location = 'D5 East/5', loot = {'electronickit'}},

    [11] = {coords = vector3(896.4039, -3074.4290, 5.9008), location = 'G5 West/1', loot = {'electronickit'}},
    [12] = {coords = vector3(896.4886, -3077.4885, 5.9008), location = 'G5 West/2', loot = {'electronickit'}},
    [13] = {coords = vector3(896.5045, -3080.0684, 5.9008), location = 'G5 West/3', loot = {'electronickit'}},
    [14] = {coords = vector3(896.4840, -3082.7954, 5.9008), location = 'G5 West/4', loot = {'electronickit'}},

    [15] = {coords = vector3(992.9855, -3074.7322, 5.9010), location = 'H5 West/1', loot = {'electronickit'}},
    [16] = {coords = vector3(992.9868, -3077.5686, 5.9010), location = 'H5 West/2', loot = {'electronickit'}},
    [17] = {coords = vector3(992.9284, -3080.2112, 5.9010), location = 'H5 West/3', loot = {'electronickit'}},
    [18] = {coords = vector3(992.9205, -3082.7610, 5.9010), location = 'H5 West/4', loot = {'electronickit'}},
    [19] = {coords = vector3(992.9531, -3085.3762, 5.9010), location = 'H5 West/5', loot = {'electronickit'}},

    [20] = {coords = vector3(993.0677, -2968.3271, 5.9008), location = 'B5 West/1', loot = {'electronickit'}},
    [21] = {coords = vector3(993.0593, -2971.0173, 5.9008), location = 'B5 West/2', loot = {'electronickit'}},
    [22] = {coords = vector3(993.1068, -2973.6677, 5.9008), location = 'B5 West/3', loot = {'electronickit'}},
    [23] = {coords = vector3(993.1347, -2976.2559, 5.9008), location = 'B5 West/4', loot = {'electronickit'}},
    [24] = {coords = vector3(993.1258, -2978.9690, 5.9008), location = 'B5 West/5', loot = {'electronickit'}},

    [25] = {coords = vector3(993.0417, -2993.3267, 5.9008), location = 'B1 East/1', loot = {'electronickit'}},
    [26] = {coords = vector3(993.0601, -2990.7529, 5.9008), location = 'B1 East/2', loot = {'electronickit'}},
    [27] = {coords = vector3(992.9528, -2988.1252, 5.9008), location = 'B1 East/3', loot = {'electronickit'}},
    [28] = {coords = vector3(993.0357, -2985.5183, 5.9008), location = 'B1 East/4', loot = {'electronickit'}},

    [29] = {coords = vector3(992.8859, -3020.9226, 5.9008), location = 'E5 West/1', loot = {'electronickit'}},
    [30] = {coords = vector3(992.9485, -3023.6611, 5.9008), location = 'E5 West/2', loot = {'electronickit'}},
    [31] = {coords = vector3(992.9437, -3026.3347, 5.9008), location = 'E5 West/3', loot = {'electronickit'}},
    [32] = {coords = vector3(992.9479, -3028.9189, 5.9008), location = 'E5 West/4', loot = {'electronickit'}},
    [33] = {coords = vector3(992.9391, -3031.5625, 5.9008), location = 'E5 West/5', loot = {'electronickit'}},

    [34] = {coords = vector3(993.1380, -3047.6982, 5.9008), location = 'E1 West/1', loot = {'electronickit'}},
    [35] = {coords = vector3(993.2062, -3045.0117, 5.9008), location = 'E1 West/2', loot = {'electronickit'}},
    [36] = {coords = vector3(993.2366, -3042.4414, 5.9008), location = 'E1 West/3', loot = {'electronickit'}},
    [37] = {coords = vector3(993.1972, -3039.8152, 5.9008), location = 'E1 West/4', loot = {'electronickit'}},
}