--=== TRANSLATION ===--
Translation = {
    ['universal'] = {
        notifications = {
            notEnoughtPolice = "Currently there are not enough police officers on duty",
            activeJob = "You are already on a mission right now, finish it first",
            location = "You will receive an email with the location shortly",
            cooldown = "Sorry, I don't have a mission right now, check back later",
            activeHeist = "Sorry, I have already given someone else this mission",
            canceled = "Canceled...",
            noTime = "You took too long, I'm looking for someone new for the mission",
            noItem = "You need a %s to do this", -- %s = item name
            noPhone = "You need a phone to do this",
        },
    },
    ['labHeist'] = {
        mail = {
            sender = "Lugo Bervic",
            subject = "Bio Research...",
            messages = {
                heistStart = "Heres the location. You Need to hack the firewall through the computer in laboratory 1 and then download that research. <br/> I will email again when I see the firewall is down!",
                heistHack = "Great you did it! Now head to the Cold Room and bring me some samples of their work and any files you see!",
                heistEnd = "Now Bring the Research, Samples and Files back to me for your payment!",
            },
        },
        notifications = {
            guads = "Guards Alerted!",
            hackFailed = "You failed Hacking, try again",
            noHackingDevice = "You have no Hacking Device",
            policeAlert = "Break in at Humane Labs, Laboratory 1!",
            disabledAlarms = "You Successfully Disabled the alarm system, head on in",
            failAlarms = "You Failed to disable the alarm system, the guards have been alerted",
            successLoot = "You Successfully open the create",
            failLoot = "You Failed open the create and ",
            noLootDevice = "You have no Loot Device",

        },
        progessBars = {
            pickup = "Getting Job...",
            firewall = "Bypass Firewall",
            download = "Downloading Research",
            files = "Gabbring Samples and Files",
            security = "Bypassing Security Alarms...",
            rerouting = "Rerouting Alarm Checks..",

        },
        blips = {
            lab = "Bio Research Lab",
            research = "Research",
            security = "Security bypass",
        },
        target = {
            startRaidLab = "Start Lab Raid",
            getPayment = "HandOver Research",
            hackReseach = "Hack Research Files",
            samples = "Streal Samples",
            security = "Bypass Security(1 Shot)",
            lockpick = "Lockpick",
        },
    },
    ['containerHeist'] = {
        mail = {
            sender = "Purux",
            subject = "Container..",
            messages = {
                loactions = "Here are the location of the containers: <br/> LOCATIONS: <br/>",
            },
        },
        notifications = {
            noMoney = "You dont have enough money",
            noItem = "You dont have the required item",
            itemBreak = "Your lockpick broke",
            finished = "You finished the heist",
            failLoot = "You failed to open the container",

        },
        progessBars = {
            pickup = "Getting Job...",
            loot = "Looting Container",
        },
        target = {
            startHeist = "Get Tip (%s$)", -- %s = amount
            container = "Open Container",
        },
        policeAlert = "Someone tries to open the container at the docks"
    }
}