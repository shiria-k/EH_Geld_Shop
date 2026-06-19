EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.Config = EHMoneyShop.Config or {}

-- WICHTIG: Auf beiden Servern dieselben MySQL-Daten eintragen.
-- Nur ServerID darf pro Server unterschiedlich sein, damit der Shop andere Items anzeigen kann.
EHMoneyShop.Config.ServerID = "server1" -- Beispiel: "sandbox", "darkrp", "server1", "server2"
EHMoneyShop.Config.CurrencyName = "Coins"
EHMoneyShop.Config.StartMoney = 500
EHMoneyShop.Config.ChatPrefix = "[EH Geld]"
EHMoneyShop.Config.SaveInterval = 120

EHMoneyShop.Config.MySQL = {
    host = "127.0.0.1",
    username = "root",
    password = "password",
    database = "gmod_moneyshop",
    port = 3306
}

-- Shop-Items.
-- servers = {"server1"} bedeutet: nur auf ServerID server1 sichtbar.
-- servers = {"server1", "server2"} bedeutet: auf beiden sichtbar.
-- Bei type:
-- weapon = Waffe geben
-- entity = Entity vor Spieler spawnen
-- money = extra Geld geben
-- command = Server-Konsole führt Command aus, Platzhalter: {steamid64}, {nick}
EHMoneyShop.Config.ShopItems = {
    medkit = {
        name = "Medkit",
        description = "Gibt dir ein Medkit.",
        price = 250,
        servers = {"server1", "server2"},
        type = "weapon",
        class = "weapon_medkit"
    },

    armor_server1 = {
        name = "Rüstung 50",
        description = "Setzt deine Rüstung auf 50. Nur Server 1.",
        price = 300,
        servers = {"server1"},
        type = "command",
        command = "eh_give_armor {steamid64} 50"
    },

    pistol_server2 = {
        name = "Pistole",
        description = "Gibt dir eine Pistole. Nur Server 2.",
        price = 450,
        servers = {"server2"},
        type = "weapon",
        class = "weapon_pistol"
    },

    bonus_money = {
        name = "Bonus Paket",
        description = "Kostet Coins und gibt dir 100 Coins zurück. Beispiel-Item.",
        price = 50,
        servers = {"server1", "server2"},
        type = "money",
        amount = 100
    }
}
