local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
vRP = Proxy.getInterface("vRP")

vRPserver = Tunnel.getInterface("vrp_pass", "vrp_pass")