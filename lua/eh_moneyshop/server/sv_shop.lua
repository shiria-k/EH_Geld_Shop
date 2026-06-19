EHMoneyShop = EHMoneyShop or {}

util.AddNetworkString("EHMoneyShop.BuyItem")

local function itemAllowedHere(item)
    if not istable(item.servers) then return true end

    for _, serverID in ipairs(item.servers) do
        if tostring(serverID) == tostring(EHMoneyShop.Config.ServerID) then
            return true
        end
    end

    return false
end

function EHMoneyShop.GetVisibleShopItems()
    local items = {}

    for id, item in pairs(EHMoneyShop.Config.ShopItems or {}) do
        if itemAllowedHere(item) then
            items[id] = {
                name = item.name or id,
                description = item.description or "",
                price = tonumber(item.price) or 0
            }
        end
    end

    return items
end

function EHMoneyShop.SendShop(ply)
    if not IsValid(ply) then return end

    net.Start("EHMoneyShop.SendShop")
        net.WriteString(EHMoneyShop.Config.ServerID or "server")
        net.WriteTable(EHMoneyShop.GetVisibleShopItems())
        net.WriteInt(EHMoneyShop.GetMoney(ply), 32)
        net.WriteString(EHMoneyShop.Config.CurrencyName or "Coins")
    net.Send(ply)
end

local function runItemAction(ply, item)
    if item.type == "weapon" then
        if not item.class then return false, "Dieses Item hat keine Waffenklasse." end
        ply:Give(item.class)
        return true
    end

    if item.type == "entity" then
        if not item.class then return false, "Dieses Item hat keine Entity-Klasse." end

        local ent = ents.Create(item.class)
        if not IsValid(ent) then return false, "Entity konnte nicht erstellt werden." end

        local pos = ply:GetEyeTrace().HitPos + Vector(0, 0, 20)
        ent:SetPos(pos)
        ent:Spawn()
        return true
    end

    if item.type == "money" then
        EHMoneyShop.AddMoney(ply, tonumber(item.amount) or 0)
        return true
    end

    if item.type == "command" then
        if not item.command then return false, "Dieses Item hat keinen Command." end

        local cmd = item.command
        cmd = string.Replace(cmd, "{steamid64}", ply:SteamID64())
        cmd = string.Replace(cmd, "{nick}", string.Replace(ply:Nick(), "\"", ""))
        game.ConsoleCommand(cmd .. "\n")
        return true
    end

    return false, "Unbekannter Item-Typ."
end

net.Receive("EHMoneyShop.BuyItem", function(_, ply)
    local id = net.ReadString()
    local item = (EHMoneyShop.Config.ShopItems or {})[id]

    if not item then
        ply:ChatPrint((EHMoneyShop.Config.ChatPrefix or "[EH Geld]") .. " Dieses Item existiert nicht.")
        return
    end

    if not itemAllowedHere(item) then
        ply:ChatPrint((EHMoneyShop.Config.ChatPrefix or "[EH Geld]") .. " Dieses Item ist auf diesem Server nicht verfügbar.")
        return
    end

    local price = math.max(0, math.floor(tonumber(item.price) or 0))

    if not EHMoneyShop.CanAfford(ply, price) then
        ply:ChatPrint((EHMoneyShop.Config.ChatPrefix or "[EH Geld]") .. " Du hast nicht genug " .. (EHMoneyShop.Config.CurrencyName or "Coins") .. ".")
        return
    end

    local ok, err = runItemAction(ply, item)
    if not ok then
        ply:ChatPrint((EHMoneyShop.Config.ChatPrefix or "[EH Geld]") .. " Kauf fehlgeschlagen: " .. tostring(err))
        return
    end

    EHMoneyShop.TakeMoney(ply, price)

    local sid = EHMoneyShop.SQL.Escape(ply:SteamID64())
    local itemID = EHMoneyShop.SQL.Escape(id)
    local serverID = EHMoneyShop.SQL.Escape(EHMoneyShop.Config.ServerID or "server")
    EHMoneyShop.SQL.Query("INSERT INTO eh_shop_purchases (steamid64, item_id, server_id, price) VALUES ('" .. sid .. "', '" .. itemID .. "', '" .. serverID .. "', " .. price .. ")")

    ply:ChatPrint((EHMoneyShop.Config.ChatPrefix or "[EH Geld]") .. " Gekauft: " .. (item.name or id) .. " für " .. price .. " " .. (EHMoneyShop.Config.CurrencyName or "Coins") .. ".")
    EHMoneyShop.SendShop(ply)
end)

-- Beispiel für command-Item aus der Config: eh_give_armor STEAMID64 50
concommand.Add("eh_give_armor", function(admin, _, args)
    if IsValid(admin) and not admin:IsAdmin() then return end

    local targetSid = args[1]
    local armor = tonumber(args[2] or 0) or 0
    if not targetSid then return end

    for _, ply in ipairs(player.GetHumans()) do
        if ply:SteamID64() == targetSid then
            ply:SetArmor(math.Clamp(armor, 0, 255))
            return
        end
    end
end)
