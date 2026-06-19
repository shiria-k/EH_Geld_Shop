EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.Version = "1.0.0"

local function inc(path)
    if SERVER then
        AddCSLuaFile(path)
    end
    include(path)
end

inc("eh_moneyshop/sh_config.lua")

if SERVER then
    include("eh_moneyshop/server/sv_sql.lua")
    include("eh_moneyshop/server/sv_money.lua")
    include("eh_moneyshop/server/sv_shop.lua")
    AddCSLuaFile("eh_moneyshop/client/cl_menu.lua")
else
    include("eh_moneyshop/client/cl_menu.lua")
end
