EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

-- =========================================================
-- EH_Charmenu Shared Config
-- Diese Datei wird auch an Clients gesendet.
-- Hier NIEMALS SQL-Passwoerter eintragen.
-- SQL-Daten gehoeren in: lua/eh_charmenu/sv_config.lua
-- =========================================================

EHChar.Config.ServerID = "metro"
EHChar.Config.MaxSlots = 3

-- Nur Zivilisten-Skins anzeigen.
-- Keine automatisch registrierten Workshop-/Job-/Polizei-/Militaer-Models.
EHChar.Config.UseAllRegisteredPlayerModels = false

EHChar.Config.WorkshopDownloads = {
    Enabled = true,
    IDs = {
        "504945881",
        "3307292172"
    }
}

EHChar.Config.DarkRPJobs = EHChar.Config.DarkRPJobs or {
    Enabled = false,
    Jobs = {}
}

-- =========================================================
-- Zivilisten-PlayerModels
-- =========================================================

EHChar.Config.AllowedModels = {
    ["Zivilist Mann 01"] = "models/player/group01/male_01.mdl",
    ["Zivilist Mann 02"] = "models/player/group01/male_02.mdl",
    ["Zivilist Mann 03"] = "models/player/group01/male_03.mdl",
    ["Zivilist Mann 04"] = "models/player/group01/male_04.mdl",
    ["Zivilist Mann 05"] = "models/player/group01/male_05.mdl",
    ["Zivilist Mann 06"] = "models/player/group01/male_06.mdl",
    ["Zivilist Mann 07"] = "models/player/group01/male_07.mdl",
    ["Zivilist Mann 08"] = "models/player/group01/male_08.mdl",
    ["Zivilist Mann 09"] = "models/player/group01/male_09.mdl",

    ["Zivilist Frau 01"] = "models/player/group01/female_01.mdl",
    ["Zivilist Frau 02"] = "models/player/group01/female_02.mdl",
    ["Zivilist Frau 03"] = "models/player/group01/female_03.mdl",
    ["Zivilist Frau 04"] = "models/player/group01/female_04.mdl",
    ["Zivilist Frau 06"] = "models/player/group01/female_06.mdl",
    ["Zivilist Frau 07"] = "models/player/group01/female_07.mdl",

    ["Zivilist Refugee Mann 01"] = "models/player/group02/male_02.mdl",
    ["Zivilist Refugee Mann 02"] = "models/player/group02/male_04.mdl",
    ["Zivilist Refugee Mann 03"] = "models/player/group02/male_06.mdl",
    ["Zivilist Refugee Frau 01"] = "models/player/group02/female_01.mdl",
    ["Zivilist Refugee Frau 02"] = "models/player/group02/female_03.mdl",
    ["Zivilist Refugee Frau 03"] = "models/player/group02/female_06.mdl"
}

EHChar.Config.Genders = {
    "Maennlich",
    "Weiblich",
    "Divers"
}
