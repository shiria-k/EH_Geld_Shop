EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.SQL = EHMoneyShop.SQL or {}
EHMoneyShop.Money = EHMoneyShop.Money or {}

local function log(msg)
    print("[EH Geld SQL] " .. msg)
end

log("SQL-Datei wurde geladen.")

local ok, err = pcall(require, "mysqloo")
if not ok then
    log("FEHLER: mysqloo konnte nicht geladen werden.")
    log("Grund: " .. tostring(err))
    log("Loesung: mysqloo muss nach garrysmod/lua/bin/ hochgeladen werden.")
    EHMoneyShop.SQL.Disabled = true
    return
end

log("mysqloo wurde geladen.")

local cfg = EHMoneyShop.Config.MySQL or {}
local db

local function validateConfig()
    local missing = {}

    if not cfg.host or cfg.host == "" or cfg.host == "127.0.0.1" then
        table.insert(missing, "host")
    end

    if not cfg.username or cfg.username == "" or cfg.username == "root" then
        table.insert(missing, "username")
    end

    if not cfg.password or cfg.password == "" or cfg.password == "password" then
        table.insert(missing, "password")
    end

    if not cfg.database or cfg.database == "" or cfg.database == "gmod_moneyshop" then
        table.insert(missing, "database")
    end

    cfg.port = tonumber(cfg.port) or 3306

    if #missing > 0 then
        log("WARNUNG: Diese MySQL-Werte sehen noch falsch oder leer aus: " .. table.concat(missing, ", "))
    end

    log("Verbindungsversuch zu " .. tostring(cfg.host) .. ":" .. tostring(cfg.port) .. " / DB: " .. tostring(cfg.database) .. " / User: " .. tostring(cfg.username))
end

function EHMoneyShop.SQL.Escape(value)
    if not db then return tostring(value or "") end
    return db:escape(tostring(value or ""))
end

function EHMoneyShop.SQL.Query(query, callback)
    if EHMoneyShop.SQL.Disabled then
        log("Query blockiert, weil SQL deaktiviert ist.")
        if callback then callback(false, "SQL deaktiviert") end
        return
    end

    if not db then
        log("Query ohne Datenbankverbindung blockiert: " .. query)
        if callback then callback(false, "Keine Datenbankverbindung") end
        return
    end

    local q = db:query(query)

    function q:onSuccess(data)
        if callback then callback(data or {}, nil) end
    end

    function q:onError(qerr)
        log("Query Fehler: " .. tostring(qerr))
        log(query)
        if callback then callback(false, qerr) end
    end

    q:start()
end

local function createTables()
    EHMoneyShop.SQL.Query([[
        CREATE TABLE IF NOT EXISTS eh_money_accounts (
            steamid64 VARCHAR(32) NOT NULL PRIMARY KEY,
            money INT NOT NULL DEFAULT 0,
            last_name VARCHAR(64) NULL,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    EHMoneyShop.SQL.Query([[
        CREATE TABLE IF NOT EXISTS eh_shop_purchases (
            id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            steamid64 VARCHAR(32) NOT NULL,
            item_id VARCHAR(64) NOT NULL,
            server_id VARCHAR(64) NOT NULL,
            price INT NOT NULL,
            bought_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_steamid64 (steamid64),
            INDEX idx_server_id (server_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

function EHMoneyShop.SQL.Connect()
    if EHMoneyShop.SQL.Disabled then return end

    validateConfig()

    db = mysqloo.connect(tostring(cfg.host), tostring(cfg.username), tostring(cfg.password), tostring(cfg.database), tonumber(cfg.port) or 3306)

    function db:onConnected()
        log("Verbunden mit MySQL.")
        createTables()
        hook.Run("EHMoneyShop.SQLReady")
    end

    function db:onConnectionFailed(qerr)
        log("Verbindung fehlgeschlagen: " .. tostring(qerr))
        log("Pruefen: host, port, username, passwort, database und Connections From.")
    end

    db:connect()
end

hook.Add("Initialize", "EHMoneyShop.SQL.Connect", function()
    EHMoneyShop.SQL.Connect()
end)
