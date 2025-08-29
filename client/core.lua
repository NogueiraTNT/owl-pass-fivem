-- client/core.lua
local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
vRP = Proxy.getInterface("vRP")

-- (opcional) interface se você quiser métodos Tunnel depois
-- local PASSserver = Tunnel.getInterface("vrp_pass")

local uiAberto = false

RegisterCommand(PassConfig.comand, function()
  uiAberto = not uiAberto
  SetNuiFocus(uiAberto, uiAberto)
  if uiAberto then
    TriggerServerEvent("owl_pass:requestRanking")
  end
end, false)

RegisterNetEvent("owl_pass:sendRanking")
AddEventHandler("owl_pass:sendRanking", function(fullData)
  if uiAberto then
    SendNUIMessage({ action = "showUI", data = fullData })
  end
end)

RegisterNUICallback('closeUI', function(_, cb)
  uiAberto = false
  SetNuiFocus(false, false)
  cb({ ok = true })
end)

RegisterNUICallback('getMissions', function(data, cb)
  local missionType = data.missionType -- "Season","Specials","Daily"
  TriggerServerEvent("owl_pass:requestMissions", missionType)
  cb({ ok = true })
end)

RegisterNetEvent("owl_pass:sendMissions")
AddEventHandler("owl_pass:sendMissions", function(missions_with_progress)
  if not uiAberto then return end
  SendNUIMessage({ action = "updateMissions", data = missions_with_progress })
end)

RegisterNUICallback('completeMission', function(data, cb)
  if data and data.mission_id then
    TriggerServerEvent("owl_pass:completeMission", data.mission_id)
  end
  cb({ ok = true })
end)

RegisterNUICallback('claimReward', function(data, cb)
  if data and data.reward_id then
    TriggerServerEvent("owl_pass:claimReward", data.reward_id)
  end
  cb({ ok = true })
end)

-- Exemplo de hook: quando um evento do jogo rolar no client, avisa o server.
-- Use o logic_type que você definiu no PassConfig (ex.: "job_delivery","police","fishing"...)
-- TriggerServerEvent("owl_pass:missionActionCompleted", "job_delivery", 1)

RegisterNetEvent("owl_pass:updateUIData")
AddEventHandler("owl_pass:updateUIData", function(fullData)
  if uiAberto then
    SendNUIMessage({ action = "updateData", data = fullData })
  end
end)

RegisterNUICallback('addPremium', function(data, cb)
  print(data)
  cb({ ok = true })
end)
