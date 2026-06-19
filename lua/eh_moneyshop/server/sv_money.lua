EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.Money = EHMoneyShop.Money or {}

util.AddNetworkString("EHMoneyShop.SyncMoney")
util.AddNetworkString("EHMoneyShop.OpenShop")
util.AddNetworkString("EHMoneyShop.SendShop")

local function prefix()
    return EHMoneyShop.Config.ChatPrefix or "[EH Geld]"
end

local function tell(ply, msg)
    if IsValid(ply) then
        ply:ChatPrint(prefix() .. " " .. msg)
    end
end

local function steamid64(ply)
    return IsValid(ply) and ply:SteamID64() or "0"
end

local function syncMoney(ply)
    if not IsValid(ply) then return end
    net.Start("EHMoneyShop.SyncMoney")
        net.WriteInt(EHMoneyShop.Money[steamid64(ply)] or 0, 32)
        net.WriteString(EHMoneyShop.Config.CurrencyName or "Coins")
    net.Send(ply)
end

function EHMoneyShop.GetMoney(ply)
    return EHMoneyShop.Money[steamid64(ply)] or 0
end

function EHMoneyShop.SetMoney(ply, amount, nosave)
    if not IsValid(ply) then return end

    amount = math.max(0, math.floor(tonumber(amount) or 0))
    local sid = steamid64(ply)
    EHMoneyShop.Money[sid] = amount
    syncMoney(ply)

    if not nosave then
        EHMoneyShop.SaveMoney(ply)
    end
end

function EHMoneyShop.AddMoney(ply, amount)
    EHMoneyShop.SetMoney(ply, EHMoneyShop.GetMoney(ply) + math.floor(tonumber(amount) or 0))
end

function EHMoneyShop.CanAfford(ply, amount)
    return EHMoneyShop.GetMoney(ply) >= math.floor(tonumber(amount) or 0)
end

function EHMoneyShop.TakeMoney(ply, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return true end
    if not EHMoneyShop.CanAfford(ply, amount) then return false end
    EHMoneyShop.SetMoney(ply, EHMoneyShop.GetMoney(ply) - amount)
    return true
end

function EHMoneyShop.LoadMoney(ply)
    if not IsValid(ply) then return end

    local sid = EHMoneyShop.SQL.Escape(steamid64(ply))
    local name = EHMoneyShop.SQL.Escape(ply:Nick())

    EHMoneyShop.SQL.Query("SELECT money FROM eh_money_accounts WHERE steamid64='" .. sid .. "' LIMIT 1", function(data)
        if not IsValid(ply) then return end

        if data and data[1] then
            EHMoneyShop.SetMoney(ply, tonumber(data[1].money) or 0, true)
        else
            local startMoney = math.floor(tonumber(EHMoneyShop.Config.StartMoney) or 0)
            EHMoneyShop.Money[steamid64(ply)] = startMoney
            EHMoneyShop.SQL.Query("INSERT INTO eh_money_accounts (steamid64, money, last_name) VALUES ('" .. sid .. "', " .. startMoney .. ", '" .. name .. "')")
            syncMoney(ply)
        end
    end)
end

function EHMoneyShop.SaveMoney(ply)
    if not IsValid(ply) then return end

    local sid = EHMoneyShop.SQL.Escape(steamid64(ply))
    local name = EHMoneyShop.SQL.Escape(ply:Nick())
    local money = math.floor(EHMoneyShop.GetMoney(ply))

    EHMoneyShop.SQL.Query("INSERT INTO eh_money_accounts (steamid64, money, last_name) VALUES ('" .. sid .. "', " .. money .. ", '" .. name .. "') ON DUPLICATE KEY UPDATE money=" .. money .. ", last_name='" .. name .. "'")
end

hook.Add("PlayerInitialSpawn", "EHMoneyShop.LoadMoney", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            EHMoneyShop.LoadMoney(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "EHMoneyShop.SaveMoney", function(ply)
    EHMoneyShop.SaveMoney(ply)
end)

timer.Create("EHMoneyShop.AutoSave", EHMoneyShop.Config.SaveInterval or 120, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        EHMoneyShop.SaveMoney(ply)
    end
end)

hook.Add("PlayerSay", "EHMoneyShop.Commands", function(ply, text)
    text = string.lower(string.Trim(text or ""))

    if text == "!geld" or text == "/geld" then
        tell(ply, "Du hast " .. EHMoneyShop.GetMoney(ply) .. " " .. (EHMoneyShop.Config.CurrencyName or "Coins") .. ".")
        return ""
    end

    if text == "!shop" or text == "/shop" then
        EHMoneyShop.SendShop(ply)
        return ""
    end
end)

concommand.Add("eh_money_add", function(admin, _, args)
    if IsValid(admin) and not admin:IsAdmin() then return end
    local targetSid = args[1]
    local amount = tonumber(args[2] or 0) or 0
    if not targetSid or amount == 0 then return end

    for _, ply in ipairs(player.GetHumans()) do
        if ply:SteamID64() == targetSid then
            EHMoneyShop.AddMoney(ply, amount)
            tell(ply, "Du hast " .. amount .. " " .. (EHMoneyShop.Config.CurrencyName or "Coins") .. " bekommen.")
            return
        end
    end

    local sid = EHMoneyShop.SQL.Escape(targetSid)
    EHMoneyShop.SQL.Query("INSERT INTO eh_money_accounts (steamid64, money) VALUES ('" .. sid .. "', " .. math.floor(amount) .. ") ON DUPLICATE KEY UPDATE money=money+" .. math.floor(amount))
end)
