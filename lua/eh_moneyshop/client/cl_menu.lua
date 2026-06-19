EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.ClientMoney = 0
EHMoneyShop.CurrencyName = "Coins"

net.Receive("EHMoneyShop.SyncMoney", function()
    EHMoneyShop.ClientMoney = net.ReadInt(32)
    EHMoneyShop.CurrencyName = net.ReadString()
end)

local function moneyText()
    return tostring(EHMoneyShop.ClientMoney or 0) .. " " .. tostring(EHMoneyShop.CurrencyName or "Coins")
end

local function drawMoneyHUD()
    local cfg = EHMoneyShop.Config and EHMoneyShop.Config.HUD or {}
    if cfg.enabled == false then return end

    local w = cfg.width or 210
    local h = cfg.height or 58
    local x = ScrW() - w - (cfg.posX or 20)
    local y = cfg.posY or 20
    local title = cfg.title or "Geld"

    draw.RoundedBox(10, x, y, w, h, Color(20, 20, 20, 210))
    draw.RoundedBox(10, x + 4, y + 4, w - 8, h - 8, Color(35, 35, 35, 220))

    draw.SimpleText(title, "DermaDefaultBold", x + 14, y + 10, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(moneyText(), "DermaLarge", x + 14, y + 26, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

hook.Add("HUDPaint", "EHMoneyShop.DrawMoneyHUD", drawMoneyHUD)

local function createShop(serverID, items, currentMoney, currency)
    EHMoneyShop.ClientMoney = currentMoney or EHMoneyShop.ClientMoney or 0
    EHMoneyShop.CurrencyName = currency or EHMoneyShop.CurrencyName or "Coins"

    if IsValid(EHMoneyShop.Frame) then
        EHMoneyShop.Frame:Remove()
    end

    local frame = vgui.Create("DFrame")
    EHMoneyShop.Frame = frame
    frame:SetSize(620, 500)
    frame:Center()
    frame:SetTitle("EH Shop - " .. tostring(serverID))
    frame:MakePopup()

    local top = vgui.Create("DLabel", frame)
    top:Dock(TOP)
    top:SetTall(35)
    top:SetText("Dein Geld: " .. moneyText())
    top:SetFont("DermaLarge")
    top:DockMargin(10, 5, 10, 5)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 5, 10, 10)

    local sorted = {}
    for id, item in pairs(items or {}) do
        table.insert(sorted, {id = id, item = item})
    end

    table.SortByMember(sorted, "id", true)

    for _, data in ipairs(sorted) do
        local id = data.id
        local item = data.item

        local panel = scroll:Add("DPanel")
        panel:Dock(TOP)
        panel:SetTall(92)
        panel:DockMargin(0, 0, 0, 8)

        local name = vgui.Create("DLabel", panel)
        name:SetPos(10, 8)
        name:SetSize(420, 22)
        name:SetText(item.name or id)
        name:SetFont("DermaDefaultBold")

        local desc = vgui.Create("DLabel", panel)
        desc:SetPos(10, 32)
        desc:SetSize(420, 42)
        desc:SetWrap(true)
        desc:SetText(item.description or "")

        local price = vgui.Create("DLabel", panel)
        price:SetPos(450, 12)
        price:SetSize(150, 22)
        price:SetText("Preis: " .. tostring(item.price or 0) .. " " .. EHMoneyShop.CurrencyName)

        local buy = vgui.Create("DButton", panel)
        buy:SetPos(450, 45)
        buy:SetSize(130, 32)
        buy:SetText("Kaufen")
        buy.DoClick = function()
            net.Start("EHMoneyShop.BuyItem")
                net.WriteString(id)
            net.SendToServer()
        end
    end
end

net.Receive("EHMoneyShop.SendShop", function()
    local serverID = net.ReadString()
    local items = net.ReadTable()
    local money = net.ReadInt(32)
    local currency = net.ReadString()

    createShop(serverID, items, money, currency)
end)

concommand.Add("eh_shop", function()
    RunConsoleCommand("say", "!shop")
end)
