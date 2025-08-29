local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local PASS = {}
Tunnel.bindInterface("vrp_pass", PASS)

function PASS.getRanking()
    local source = source
    local user_id = vRP.getUserId({source})
    if user_id then
        return getRankingData(user_id)
    end
end
