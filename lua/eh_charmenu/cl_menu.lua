EHChar = EHChar or {}
EHChar.ClientCharacters = EHChar.ClientCharacters or {}

local COL_BG = Color(18, 22, 28, 245)
local COL_PANEL = Color(30, 35, 44, 245)
local COL_PANEL_2 = Color(40, 47, 58, 245)
local COL_ACCENT = Color(80, 160, 255)
local COL_TEXT = Color(235, 235, 235)
local COL_MUTED = Color(170, 175, 185)
local COL_GREEN = Color(80, 200, 120)

local function notify(text)
    chat.AddText(COL_ACCENT, "[EHChar] ", color_white, tostring(text or ""))
end

local function paintPanel(_, w, h)
    surface.SetDrawColor(COL_PANEL)
    surface.DrawRect(0, 0, w, h)
end

local function paintPanel2(_, w, h)
    surface.SetDrawColor(COL_PANEL_2)
    surface.DrawRect(0, 0, w, h)
end

local function styleButton(btn, accent)
    btn:SetTextColor(color_white)
    btn.Paint = function(self, w, h)
        local col = accent or COL_PANEL_2
        if self:IsHovered() then
            col = Color(math.min(col.r + 25, 255), math.min(col.g + 25, 255), math.min(col.b + 25, 255), col.a)
        end
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(COL_ACCENT)
        surface.DrawRect(0, h - 2, w, 2)
    end
end

net.Receive("EHChar_Notify", function() notify(net.ReadString()) end)
net.Receive("EHChar_SendCharacters", function() EHChar.ClientCharacters = net.ReadTable() or {} end)

local function getCharacterBySlot(slot)
    for _, char in ipairs(EHChar.ClientCharacters or {}) do
        if tonumber(char.slot) == tonumber(slot) then return char end
    end
    return nil
end

local function modelChoices()
    local choices = {}
    local used = {}

    for name, mdl in SortedPairs(EHChar.Config.AllowedModels or {}) do
        mdl = tostring(mdl or "")
        if mdl ~= "" and not used[string.lower(mdl)] then
            used[string.lower(mdl)] = true
            choices[#choices + 1] = {name = tostring(name), model = mdl}
        end
    end

    return choices
end

local function decodeBodygroups(value)
    if istable(value) then return value end
    return util.JSONToTable(tostring(value or "{}")) or {}
end

local function applyBodygroups(ent, bodygroups)
    if not IsValid(ent) then return end
    for id, value in pairs(bodygroups or {}) do
        ent:SetBodygroup(tonumber(id) or 0, tonumber(value) or 0)
    end
end

local function addLabel(parent, text, tall, font, color)
    local lbl = vgui.Create("DLabel", parent)
    lbl:Dock(TOP)
    lbl:SetTall(tall or 24)
    lbl:SetText(text or "")
    lbl:SetFont(font or "DermaDefaultBold")
    lbl:SetTextColor(color or COL_TEXT)
    return lbl
end

local function buildBodygroupControls(parent, preview, bodygroups, refresh)
    parent:Clear()

    if not IsValid(preview) or not IsValid(preview.Entity) then
        addLabel(parent, "Kein Model geladen.", 30, "DermaDefault", COL_MUTED)
        return
    end

    local ent = preview.Entity
    local found = false

    for id = 0, ent:GetNumBodyGroups() - 1 do
        local count = ent:GetBodygroupCount(id)
        if count and count > 1 then
            found = true
            local slider = vgui.Create("DNumSlider", parent)
            slider:Dock(TOP)
            slider:DockMargin(0, 3, 0, 3)
            slider:SetTall(40)
            slider:SetText(ent:GetBodygroupName(id) ~= "" and ent:GetBodygroupName(id) or ("Bodygroup " .. id))
            slider:SetMin(0)
            slider:SetMax(count - 1)
            slider:SetDecimals(0)
            slider:SetValue(tonumber(bodygroups[tostring(id)] or bodygroups[id] or 0) or 0)
            slider.OnValueChanged = function(_, value)
                bodygroups[tostring(id)] = math.floor(value)
                if refresh then refresh() end
            end
        end
    end

    if not found then
        local info = addLabel(parent, "Dieses Zivilisten-Model hat keine Kleidung/Bodygroups.", 46, "DermaDefault", COL_MUTED)
        info:SetWrap(true)
    end
end

local function createEditor(parent, slot, existing)
    parent:Clear()

    local root = vgui.Create("DPanel", parent)
    root:Dock(FILL)
    root:DockMargin(12, 12, 12, 12)
    root.Paint = nil

    addLabel(root, existing and ("Slot " .. slot .. " bearbeiten") or ("Slot " .. slot .. " erstellen"), 38, "DermaLarge", color_white)
    addLabel(root, "Nur Zivilisten-Skins sind erlaubt.", 24, "DermaDefault", COL_MUTED)

    local content = vgui.Create("DPanel", root)
    content:Dock(FILL)
    content:DockMargin(0, 10, 0, 0)
    content.Paint = nil

    local left = vgui.Create("DScrollPanel", content)
    left:Dock(LEFT)
    left:SetWide(340)
    left:DockMargin(0, 0, 14, 0)

    local right = vgui.Create("DPanel", content)
    right:Dock(FILL)
    right.Paint = paintPanel2

    addLabel(left, "Charakterdaten", 26)

    local nameEntry = vgui.Create("DTextEntry", left)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 4, 0, 8)
    nameEntry:SetTall(34)
    nameEntry:SetPlaceholderText("Vorname Nachname")
    nameEntry:SetValue(existing and tostring(existing.char_name or "") or "")

    local genderBox = vgui.Create("DComboBox", left)
    genderBox:Dock(TOP)
    genderBox:DockMargin(0, 0, 0, 8)
    genderBox:SetTall(34)
    genderBox:SetValue(existing and tostring(existing.gender or "Geschlecht waehlen") or "Geschlecht waehlen")
    for _, gender in ipairs(EHChar.Config.Genders or {}) do genderBox:AddChoice(gender) end

    addLabel(left, "Zivilisten-Skin", 26)

    local choices = modelChoices()
    local selectedModel = existing and tostring(existing.model or "") or ""
    if selectedModel == "" and choices[1] then selectedModel = choices[1].model end

    local modelBox = vgui.Create("DComboBox", left)
    modelBox:Dock(TOP)
    modelBox:DockMargin(0, 4, 0, 8)
    modelBox:SetTall(34)
    modelBox:SetValue("Zivilisten-Skin waehlen")
    for _, choice in ipairs(choices) do
        modelBox:AddChoice(choice.name, choice.model)
        if selectedModel == choice.model then modelBox:SetValue(choice.name) end
    end

    local previewTitle = addLabel(right, "Vorschau", 30, "DermaDefaultBold", COL_TEXT)
    previewTitle:DockMargin(10, 8, 10, 0)

    local preview = vgui.Create("DModelPanel", right)
    preview:Dock(TOP)
    preview:DockMargin(10, 4, 10, 10)
    preview:SetTall(345)
    preview:SetModel(selectedModel ~= "" and selectedModel or "models/player/group01/male_01.mdl")
    preview:SetFOV(36)
    preview:SetCamPos(Vector(62, 0, 62))
    preview:SetLookAt(Vector(0, 0, 44))
    preview.LayoutEntity = function(_, ent)
        ent:SetAngles(Angle(0, RealTime() * 18 % 360, 0))
    end

    local skinSlider = vgui.Create("DNumSlider", left)
    skinSlider:Dock(TOP)
    skinSlider:DockMargin(0, 0, 0, 8)
    skinSlider:SetTall(42)
    skinSlider:SetText("Skin / Variante")
    skinSlider:SetMin(0)
    skinSlider:SetMax(8)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(existing and tonumber(existing.skin) or 0)

    local bodygroups = decodeBodygroups(existing and existing.bodygroups or "{}")

    local function refreshPreview()
        if IsValid(preview.Entity) then
            preview.Entity:SetSkin(math.floor(skinSlider:GetValue()))
            applyBodygroups(preview.Entity, bodygroups)
        end
    end

    local bodyTitle = addLabel(left, "Kleidung / Bodygroups", 26)
    bodyTitle:DockMargin(0, 6, 0, 0)

    local bodyPanel = vgui.Create("DScrollPanel", left)
    bodyPanel:Dock(TOP)
    bodyPanel:SetTall(170)
    bodyPanel.Paint = paintPanel2

    local function rebuildBodygroups()
        timer.Simple(0, function()
            if not IsValid(bodyPanel) then return end
            buildBodygroupControls(bodyPanel, preview, bodygroups, refreshPreview)
            refreshPreview()
        end)
    end

    skinSlider.OnValueChanged = function() refreshPreview() end
    modelBox.OnSelect = function(_, _, _, model)
        selectedModel = model
        bodygroups = {}
        preview:SetModel(model)
        rebuildBodygroups()
    end

    rebuildBodygroups()

    local save = vgui.Create("DButton", left)
    save:Dock(TOP)
    save:DockMargin(0, 12, 0, 0)
    save:SetTall(42)
    save:SetText(existing and "Charakter speichern" or "Charakter erstellen")
    styleButton(save, COL_GREEN)
    save.DoClick = function()
        local _, model = modelBox:GetSelected()
        model = model or selectedModel or ""

        net.Start("EHChar_SaveCharacter")
            net.WriteTable({
                slot = slot,
                char_name = nameEntry:GetValue(),
                gender = genderBox:GetValue(),
                model = model,
                skin = math.floor(skinSlider:GetValue()),
                bodygroups = bodygroups
            })
        net.SendToServer()
    end
end

local function createJobPanel(parent)
    parent:Clear()
    local box = vgui.Create("DPanel", parent)
    box:Dock(FILL)
    box:DockMargin(12, 12, 12, 12)
    box.Paint = paintPanel

    addLabel(box, "Stadt-Jobdaten", 38, "DermaLarge")

    if EHChar.Config.ServerID ~= "stadt" then
        local label = addLabel(box, "Jobdaten sind nur auf dem Stadt-/DarkRP-Server aktiv.", 50, "DermaDefault", COL_MUTED)
        label:SetWrap(true)
        return
    end

    addLabel(box, "Noch keine zivilen Jobdaten eingetragen.", 30, "DermaDefault", COL_MUTED)
end

function EHChar.OpenMenu()
    if IsValid(EHChar.Frame) then EHChar.Frame:Remove() end

    local frame = vgui.Create("DFrame")
    EHChar.Frame = frame
    frame:SetSize(980, 660)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(_, w, h)
        surface.SetDrawColor(COL_BG)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(COL_ACCENT)
        surface.DrawRect(0, 0, w, 4)
    end

    local title = vgui.Create("DLabel", frame)
    title:Dock(TOP)
    title:DockMargin(14, 8, 14, 0)
    title:SetTall(42)
    title:SetText("Echo Hunt Charaktermenue")
    title:SetFont("DermaLarge")
    title:SetTextColor(color_white)

    local main = vgui.Create("DPanel", frame)
    main:Dock(FILL)
    main:DockMargin(12, 6, 12, 12)
    main.Paint = nil

    local left = vgui.Create("DPanel", main)
    left:Dock(LEFT)
    left:SetWide(285)
    left:DockMargin(0, 0, 12, 0)
    left.Paint = paintPanel

    local right = vgui.Create("DPanel", main)
    right:Dock(FILL)
    right.Paint = paintPanel

    local h = addLabel(left, "Charakter-Slots", 34, "DermaDefaultBold")
    h:DockMargin(10, 8, 10, 0)

    for slot = 1, EHChar.Config.MaxSlots or 3 do
        local char = getCharacterBySlot(slot)
        local btn = vgui.Create("DButton", left)
        btn:Dock(TOP)
        btn:DockMargin(10, 8, 10, 0)
        btn:SetTall(58)
        btn:SetText(char and ("Slot " .. slot .. "\n" .. tostring(char.char_name)) or ("Slot " .. slot .. "\nLeer"))
        styleButton(btn, char and COL_ACCENT or COL_PANEL_2)
        btn.DoClick = function()
            if char then
                net.Start("EHChar_SelectCharacter")
                    net.WriteUInt(slot, 3)
                net.SendToServer()
            end
            createEditor(right, slot, getCharacterBySlot(slot))
        end
    end

    local refresh = vgui.Create("DButton", left)
    refresh:Dock(BOTTOM)
    refresh:DockMargin(10, 6, 10, 10)
    refresh:SetTall(36)
    refresh:SetText("Aktualisieren")
    styleButton(refresh)
    refresh.DoClick = function()
        net.Start("EHChar_RequestCharacters")
        net.SendToServer()
        timer.Simple(0.25, function()
            if IsValid(frame) then EHChar.OpenMenu() end
        end)
    end

    local jobs = vgui.Create("DButton", left)
    jobs:Dock(BOTTOM)
    jobs:DockMargin(10, 6, 10, 0)
    jobs:SetTall(36)
    jobs:SetText("Jobdaten")
    styleButton(jobs)
    jobs.DoClick = function() createJobPanel(right) end

    createEditor(right, 1, getCharacterBySlot(1))
end

net.Receive("EHChar_OpenMenu", function() EHChar.OpenMenu() end)

concommand.Add("eh_chars", function()
    net.Start("EHChar_RequestCharacters")
    net.SendToServer()
    timer.Simple(0.2, EHChar.OpenMenu)
end)
