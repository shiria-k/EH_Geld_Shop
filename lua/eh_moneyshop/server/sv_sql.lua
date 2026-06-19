EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.SQL = EHMoneyShop.SQL or {}
EHMoneyShop.Money = EHMoneyShop.Money or {}

require("mysqloo")

local cfg = EHMoneyShop.Config.MySQL
local db

local function log(msg)
    print("[EH Geld SQL] " .. msg)
end

function EHMoneyShop.SQL.Escape(value)
    if not db then return tostring(value or "") end
    return db:escape(tostring(value or ""))
end

function EHMoneyShop.SQL.Query(query, callback)
    if not db then
        log("Query ohne Datenbankverbindung blockiert: " .. query)
        if callback then callback(false, "Keine Datenbankverbindung") end
        return
    end

    local q = db:query(query)

    function q:onSuccess(data)
        if callback then callback(data or {}, nil) end
    end

    function q:onError(err)
        log("Query Fehler: " .. err)
        log(query)
        if callback then callback(false, err) end
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
    db = mysqloo.connect(cfg.host, cfg.username, cfg.password, cfg.database, cfg.port)

    function db:onConnected()
        log("Verbunden mit MySQL.")
        createTables()
        hook.Run("EHMoneyShop.SQLReady")
    end

    function db:onConnectionFailed(err)
        log("Verbindung fehlgeschlagen: " .. err)
    end

    db:connect()
end

hook.Add("Initialize", "EHMoneyShop.SQL.Connect", function()
    EHMoneyShop.SQL.Connect()
end)
