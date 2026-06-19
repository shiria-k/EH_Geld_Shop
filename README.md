# EH Geld Shop

Garry's-Mod-Geldsystem mit zentraler MySQL-Speicherung und serverübergreifendem Shop.

## Was das Addon kann

- Geld wird pro Spieler über `SteamID64` gespeichert.
- Mehrere Server können denselben Geldstand nutzen, wenn beide dieselbe MySQL-Datenbank verwenden.
- Shop-Items können pro Server unterschiedlich angezeigt werden.
- Spieler öffnen den Shop mit `!shop` oder `/shop`.
- Spieler prüfen ihren Kontostand mit `!geld` oder `/geld`.
- Käufe werden in der Tabelle `eh_shop_purchases` protokolliert.

## Voraussetzungen

- Garry's Mod Dedicated Server
- MySQL- oder MariaDB-Datenbank
- `mysqloo` Binary-Modul auf dem Server

Ohne `mysqloo` funktioniert die externe SQL-Verbindung nicht. Normales Garry's-Mod-SQLite reicht nicht für mehrere Server, weil SQLite nur lokal auf einem Server speichert.

## Installation

1. Addon in den Ordner `garrysmod/addons/EH_Geld_Shop` legen.
2. Auf beiden Servern `mysqloo` installieren.
3. In `lua/eh_moneyshop/sh_config.lua` die MySQL-Daten eintragen.
4. Auf Server 1 z. B. setzen:

```lua
EHMoneyShop.Config.ServerID = "server1"
```

5. Auf Server 2 z. B. setzen:

```lua
EHMoneyShop.Config.ServerID = "server2"
```

6. Beide Server neustarten.

## MySQL-Konfiguration

Datei:

```text
lua/eh_moneyshop/sh_config.lua
```

Beispiel:

```lua
EHMoneyShop.Config.MySQL = {
    host = "127.0.0.1",
    username = "root",
    password = "password",
    database = "gmod_moneyshop",
    port = 3306
}
```

Die Tabellen werden beim Start automatisch erstellt:

- `eh_money_accounts`
- `eh_shop_purchases`

## Shop pro Server einstellen

In `ShopItems` gibt `servers` an, auf welchen Servern das Item sichtbar ist.

```lua
medkit = {
    name = "Medkit",
    description = "Gibt dir ein Medkit.",
    price = 250,
    servers = {"server1", "server2"},
    type = "weapon",
    class = "weapon_medkit"
}
```

Nur Server 1:

```lua
armor_server1 = {
    name = "Rüstung 50",
    description = "Nur auf Server 1 sichtbar.",
    price = 300,
    servers = {"server1"},
    type = "command",
    command = "eh_give_armor {steamid64} 50"
}
```

Nur Server 2:

```lua
pistol_server2 = {
    name = "Pistole",
    description = "Nur auf Server 2 sichtbar.",
    price = 450,
    servers = {"server2"},
    type = "weapon",
    class = "weapon_pistol"
}
```

## Item-Typen

### Waffe geben

```lua
type = "weapon",
class = "weapon_pistol"
```

### Entity spawnen

```lua
type = "entity",
class = "prop_physics"
```

### Geld geben

```lua
type = "money",
amount = 100
```

### Server-Command ausführen

```lua
type = "command",
command = "eh_give_armor {steamid64} 50"
```

Platzhalter:

- `{steamid64}`
- `{nick}`

## Admin-Command

Geld geben:

```text
eh_money_add STEAMID64 BETRAG
```

Beispiel:

```text
eh_money_add 76561198000000000 500
```

## Dateien

```text
lua/autorun/eh_moneyshop.lua
lua/eh_moneyshop/sh_config.lua
lua/eh_moneyshop/server/sv_sql.lua
lua/eh_moneyshop/server/sv_money.lua
lua/eh_moneyshop/server/sv_shop.lua
lua/eh_moneyshop/client/cl_menu.lua
```

## Hinweis

Das System ist bewusst als eigenes Geldsystem gebaut. Es ersetzt nicht automatisch DarkRP-Geld. Wenn du willst, kann man später eine DarkRP-Anbindung ergänzen, damit Geld auch mit `DarkRPVars.money` synchronisiert wird.
