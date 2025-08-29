bankModule = {}
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
bankServer = Tunnel.getInterface("require_bank")
Tunnel.bindInterface("require_bank", bankModule)
Proxy.addInterface("require_bank", bankModule)
Remote = Tunnel.getInterface('require_bank')