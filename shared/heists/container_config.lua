--=== CONTAINER RAID STUFF ===--

Config.ContainerHeistTime = 600 -- Time in seconds to complete the heist
Config.ContainerBoss = {
    model = 'cs_floyd',
    location = vector4(675.0380, -2725.8582, 7.1711, 178.8531),
}

Config.ContainerItem = 'lockpick' -- Item required to open a container
Config.BreakChange = 50 -- Chance in % to break the item while opening a container

Config.ContainerFee = math.random(1000, 5000) -- Amount of money you have to pay to get container locations

--== CONTAINER MINIGAME SETTINGS ==--
Config.ContainerMinigameTime = 8 -- Time in seconds for the minigame
Config.ContainerNumberOfCircles = 4 -- Number of circles in the minigame


--== CONTAINER == --
Config.MinContainer = 2 -- Minimum amount of containers to break
Config.MaxContainer = 4 -- Maximum amount of containers to break
Config.LootAmount = {min = 1, max = 3}
Config.Container = {
    [1] = {coords = vector3(896.4028, -3023.6819, 5.9020), location = 'D5 West/2', loot = {'sandwich'}},
    [2] = {coords = vector3(896.4840, -3026.3210, 5.9020), location = 'D5 West/3', loot = {'sandwich'}},
    [3] = {coords = vector3(896.4805, -3028.9470, 5.9020), location = 'D5 West/4', loot = {'sandwich'}},
    [4] = {coords = vector3(896.4009, -3031.4707, 5.9020), location = 'D5 West/5', loot = {'sandwich'}},

    [5] = {coords = vector3(896.3021, -3047.4612, 5.9020), location = 'D1 East/1', loot = {'sandwich'}},

    [6] = {coords = vector3(965.0945, -3047.4458, 5.9020), location = 'D5 East/1', loot = {'sandwich'}},
    [7] = {coords = vector3(965.0499, -3044.8245, 5.9020), location = 'D5 East/2', loot = {'sandwich'}},
    [8] = {coords = vector3(965.1483, -3042.2615, 5.9020), location = 'D5 East/3', loot = {'sandwich'}},
    [9] = {coords = vector3(965.1497, -3039.2942, 5.9020), location = 'D5 East/4', loot = {'sandwich'}},
    [10] = {coords = vector3(965.2185, -3037.0554, 5.9020), location = 'D5 East/5', loot = {'sandwich'}},

    [11] = {coords = vector3(896.4039, -3074.4290, 5.9008), location = 'G5 West/1', loot = {'sandwich'}},
    [12] = {coords = vector3(896.4886, -3077.4885, 5.9008), location = 'G5 West/2', loot = {'sandwich'}},
    [13] = {coords = vector3(896.5045, -3080.0684, 5.9008), location = 'G5 West/3', loot = {'sandwich'}},
    [14] = {coords = vector3(896.4840, -3082.7954, 5.9008), location = 'G5 West/4', loot = {'sandwich'}},

    [15] = {coords = vector3(992.9855, -3074.7322, 5.9010), location = 'H5 West/1', loot = {'sandwich'}},
    [16] = {coords = vector3(992.9868, -3077.5686, 5.9010), location = 'H5 West/2', loot = {'sandwich'}},
    [17] = {coords = vector3(992.9284, -3080.2112, 5.9010), location = 'H5 West/3', loot = {'sandwich'}},
    [18] = {coords = vector3(992.9205, -3082.7610, 5.9010), location = 'H5 West/4', loot = {'sandwich'}},
    [19] = {coords = vector3(992.9531, -3085.3762, 5.9010), location = 'H5 West/5', loot = {'sandwich'}},

    [20] = {coords = vector3(993.0677, -2968.3271, 5.9008), location = 'B5 West/1', loot = {'sandwich'}},
    [21] = {coords = vector3(993.0593, -2971.0173, 5.9008), location = 'B5 West/2', loot = {'sandwich'}},
    [22] = {coords = vector3(993.1068, -2973.6677, 5.9008), location = 'B5 West/3', loot = {'sandwich'}},
    [23] = {coords = vector3(993.1347, -2976.2559, 5.9008), location = 'B5 West/4', loot = {'sandwich'}},
    [24] = {coords = vector3(993.1258, -2978.9690, 5.9008), location = 'B5 West/5', loot = {'sandwich'}},

    [25] = {coords = vector3(993.0417, -2993.3267, 5.9008), location = 'B1 East/1', loot = {'sandwich'}},
    [26] = {coords = vector3(993.0601, -2990.7529, 5.9008), location = 'B1 East/2', loot = {'sandwich'}},
    [27] = {coords = vector3(992.9528, -2988.1252, 5.9008), location = 'B1 East/3', loot = {'sandwich'}},
    [28] = {coords = vector3(993.0357, -2985.5183, 5.9008), location = 'B1 East/4', loot = {'sandwich'}},

    [29] = {coords = vector3(992.8859, -3020.9226, 5.9008), location = 'E5 West/1', loot = {'sandwich'}},
    [30] = {coords = vector3(992.9485, -3023.6611, 5.9008), location = 'E5 West/2', loot = {'sandwich'}},
    [31] = {coords = vector3(992.9437, -3026.3347, 5.9008), location = 'E5 West/3', loot = {'sandwich'}},
    [32] = {coords = vector3(992.9479, -3028.9189, 5.9008), location = 'E5 West/4', loot = {'sandwich'}},
    [33] = {coords = vector3(992.9391, -3031.5625, 5.9008), location = 'E5 West/5', loot = {'sandwich'}},

    [34] = {coords = vector3(993.1380, -3047.6982, 5.9008), location = 'E1 West/1', loot = {'sandwich'}},
    [35] = {coords = vector3(993.2062, -3045.0117, 5.9008), location = 'E1 West/2', loot = {'sandwich'}},
    [36] = {coords = vector3(993.2366, -3042.4414, 5.9008), location = 'E1 West/3', loot = {'sandwich'}},
    [37] = {coords = vector3(993.1972, -3039.8152, 5.9008), location = 'E1 West/4', loot = {'sandwich'}},
}