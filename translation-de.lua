--=== TRANSLATION ===--
-- To use this file you need to remove the following line from fxmanfest.lua:
-- "translation.lua",
-- And add the following line:
-- "translation-de.lua", 
Translation = {
    ['universal'] = {
        notifications = {
            notEnoughtPolice = "Derzeit sind nicht genügend Polizeibeamte im Dienst",
            activeJob = "Du bist bereits auf einer Mission, beende diese zuerst",
            location = "Du wirst in Kürze eine E-Mail mit dem Standort erhalten.",
            cooldown = "Sorry, aber ich habe aktuell keine Mission für dich. Schau später nochmal vorbei",
            activeHeist = "Sorry, aber ich hab bereits jemanden für diesen Job",
            canceled = "Abgebrochen...",
            noTime = "Du hast zu lange gebraucht, ich suche mit jemand anderen für die Mission",
            noItem = "Du braucht ein %s um das zu machen", -- %s = item name
            noPhone = "Du brauchst ein Handy für diese Mission",
        },
    },
    ['labHeist'] = {
        mail = {
            sender = "Lugo Bervic",
            subject = "Bioforschung...",
            messages = {
                heistStart = "Hier ist der Standort. Du musst die Firewall über den Computer in Labor 1 hacken und dann die Forschungsergebnisse herunterladen.<br/> Ich werde erneut eine E-Mail senden, wenn ich sehe, dass die Firewall nicht mehr funktioniert!",
                heistHack = "Toll, dass du es geschafft hast! Gehe jetzt in den Kühlraum und bringe mir einige Arbeitsproben und alle Dateien, die du findest!",
                heistEnd = "Bringe jetzt die Forschung, Proben und Dateien zurück zu mir für die bezahlung!",
            },
        },
        notifications = {
            guads = "Wachen alarmiert!",
            hackFailed = "Du bist beim Hacken gescheitert, versuche es erneut",
            noHackingDevice = "Du hast kein Hacking-Gerät",
            policeAlert = "Einbruch in Humane Labs, Labor 1!",
            disabledAlarms = "Du hast das Alarmsystem erfolgreich ausgeschaltet, geh rein",
            failAlarms = "Du konntest die Alarmanlage nicht deaktivieren, die Wachen wurden alarmiert",
            successLoot = "Du hast die Anlage erfolgreich geöffnet",
            failLoot = "Du konntest die Anlage nicht öffnen und ",
            noLootDevice = "Du hast kein Beutegerät",

        },
        progessBars = {
            pickup = "Getting Job...",
            firewall = "Firewall umgehen",
            download = "Forschung herunterladen",
            files = "Beispiele und Dateien abrufen",
            security = "Sicherheitsalarme umgehen...",
            rerouting = "Alarmüberprüfungen umleiten...",

        },
        blips = {
            lab = "Bio Research Lab",
            research = "Research",
            security = "Security bypass",
        },
        target = {
            startRaidLab = "Laborüberfall starten",
            getPayment = "Übergabe Forschung",
            hackReseach = "Forschungsdateien hacken",
            samples = "Forschungsproben stehlen",
            security = "Alarm umgehen (1 Versuch)",
            lockpick = "Lockpick",
        },
    },
    ['containerHeist'] = {
        mail = {
            sender = "Jeremy C. Bickley",
            subject = "Container..",
            messages = {
                loactions = "Hey, ich habe von ein paar Containern an den Docks erfahren, in denen sich wertvolle Sachen befinden sollen. <br/> Hier sind die Lagerpositionen <br/>",
            },
        },
        notifications = {
            noMoney = "Du hast nicht genug Geld",
            noItem = "Du hast den benötigten Gegenstand nicht",
            itemBreak = "Dein Dietrich ist kaputt",
            finished = "Du hast den Raub beendet",
            failLoot = "Du konntest den Container nicht öffnen, versuche es erneut",

        },
        progessBars = {
            pickup = "Job bekommen...",
            loot = "Container plündern",
        },
        target = {
            startHeist = "Tip bekommen (%s$)", -- %s = amount
            container = "Container öffnen",
        },
        policeAlert = "Jemand versucht, die Container an den Docks zu öffnens",
    },
}