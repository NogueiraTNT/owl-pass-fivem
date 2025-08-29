-- server/core.lua
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy  = module("vrp", "lib/Proxy")
vRP          = Proxy.getInterface("vRP")
local PASS   = {}
Tunnel.bindInterface("vrp_pass", PASS)

-- ===== Helpers =====

local function ensureUserRow(user_id)
  local r = vRP.query("owl_pass/get_user_ranking", { user_id = user_id })
  if not r or #r == 0 then
    vRP.execute("owl_pass/insert_user_row", { user_id = user_id })
  end
end

local function GetXPForLevel(level)
  -- curva configurável (usa PassConfig)
  if level >= PassConfig.LevelMax then return math.huge end
  return math.floor(PassConfig.XP_BASE * (level ^ PassConfig.XP_MULTIPLIER))
end

local function AddXP(user_id, amount)
  ensureUserRow(user_id)
  local src = vRP.getUserSource({ user_id })
  if not src then return end

  local result = vRP.query("owl_pass/get_user_ranking", { user_id = user_id })
  if not result or #result == 0 then return end

  local p = result[1]
  p.xp = p.xp + amount

  local xpForNext = GetXPForLevel(p.level)
  local leveled   = false

  while p.xp >= xpForNext do
    if p.level >= PassConfig.LevelMax then
      p.xp = xpForNext
      break
    end
    leveled = true
    p.xp    = p.xp - xpForNext
    p.level = p.level + 1
    vRPclient.notify(src, {"~g~Subiu para o nível "..p.level.." do Passe!"})
    xpForNext = GetXPForLevel(p.level)
  end

  vRP.execute("owl_pass/update_user_xp_level", {
    user_id = user_id, xp = p.xp, level = p.level
  })

  vRPclient.notify(src, {"~y~+"..amount.." XP"})

  -- Atualiza UI
  local fullData = (function()
    local ranking_list = {}
    local top = vRP.query("owl_pass/get_ranking", {})
    if top and #top > 0 then
      for i,v in ipairs(top) do
        local idt = vRP.getUserIdentity({ v.user_id })
        if idt then
          ranking_list[#ranking_list+1] = {
            lugar = tostring(i),
            name  = idt.firstname.." "..idt.lastname,
            id    = v.user_id,
            xp    = v.xp,
            level = v.level
          }
        end
      end
    end

    local player_data = {}
    local pr = vRP.query("owl_pass/get_user_ranking", { user_id = user_id })
    if pr and #pr > 0 then
      local idt = vRP.getUserIdentity({ user_id })
      player_data = {
        id    = user_id,
        name  = idt and (idt.firstname.." "..idt.lastname) or ("ID "..user_id),
        xp    = pr[1].xp,
        level = pr[1].level,
        pass  = pr[1].pass
      }
    end

    local all = vRP.query("owl_pass/get_all_players_ordered", {})
    local pos = 0
    if all and #all > 0 then
      for i,v in ipairs(all) do
        if v.user_id == user_id then pos = i break end
      end
    end
    player_data.rankingPosition = pos

    return { rankingList = ranking_list, playerData = player_data }
  end)()

  TriggerClientEvent("owl_pass:updateUIData", src, fullData)
end

-- ===== Ranking via NUI =====
RegisterNetEvent("owl_pass:requestRanking")
AddEventHandler("owl_pass:requestRanking", function()
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  -- reaproveita o cálculo acima (parte funcional idêntica)
  local ranking_list = {}
  local top = vRP.query("owl_pass/get_ranking", {})
  if top and #top > 0 then
    for i,v in ipairs(top) do
      local idt = vRP.getUserIdentity({ v.user_id })
      if idt then
        ranking_list[#ranking_list+1] = {
          lugar = tostring(i),
          name  = idt.firstname.." "..idt.lastname,
          id    = v.user_id,
          xp    = v.xp,
          level = v.level
        }
      end
    end
  end

  local player_data = {}
  local pr = vRP.query("owl_pass/get_user_ranking", { user_id = user_id })
  if pr and #pr > 0 then
    local idt = vRP.getUserIdentity({ user_id })
    player_data = {
      id    = user_id,
      name  = idt and (idt.firstname.." "..idt.lastname) or ("ID "..user_id),
      xp    = pr[1].xp,
      level = pr[1].level,
      pass  = pr[1].pass
    }
  end

  local all = vRP.query("owl_pass/get_all_players_ordered", {})
  local pos = 0
  if all and #all > 0 then
    for i,v in ipairs(all) do
      if v.user_id == user_id then pos = i break end
    end
  end
  player_data.rankingPosition = pos

  TriggerClientEvent("owl_pass:sendRanking", src, {
    rankingList = ranking_list, playerData = player_data
  })
end)

-- ===== Popular DB com PassConfig (missões) =====
local function PopulateMissionsDatabase()
  print("[owl_pass] conferindo catálogo de missões...")
  local inserted = 0
  for category, data in pairs(PassConfig.Missions) do
    for _,m in ipairs(data.list) do
      local r = vRP.query("owl_pass/get_mission_by_logic_type", { logic_type = m.type })
      if #r == 0 then
        vRP.execute("owl_pass/insert_mission", {
          mission_type = category,
          title       = m.title,
          logic_type  = m.type,
          objective   = m.objective,
          xp_reward   = data.xp_reward,
          reward_pool = data.reward_pool -- pode ser nil
        })
        inserted = inserted + 1
      end
    end
  end
  if inserted > 0 then
    print("[owl_pass] "..inserted.." missões inseridas.")
  else
    print("[owl_pass] catálogo OK, sem novidades.")
  end
end

Citizen.CreateThread(function()
  Citizen.Wait(3000)
  PopulateMissionsDatabase()
end)

-- ===== NUI: listar missões + progresso real =====
RegisterNetEvent("owl_pass:requestMissions")
AddEventHandler("owl_pass:requestMissions", function(missionType)
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  local missions_with_progress = {}
  local cat = PassConfig.Missions[missionType]
  if not cat then
    TriggerClientEvent("owl_pass:sendMissions", src, missions_with_progress)
    return
  end

  for _, mission in ipairs(cat.list) do
    local prog = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = mission.id })
    local progress, completed = 0, false
    if #prog > 0 then
      progress  = prog[1].progress
      completed = (prog[1].completed == 1)
    end
    missions_with_progress[#missions_with_progress+1] = {
      id = mission.id,
      title = mission.title,
      objective = mission.objective,
      xp = cat.xp_reward,
      progress = progress,
      completed = completed
    }
  end

  TriggerClientEvent("owl_pass:sendMissions", src, missions_with_progress)
end)

-- ===== Progresso (manual via NUI ou hooks automáticos) =====
RegisterNetEvent("owl_pass:updateProgress")
AddEventHandler("owl_pass:updateProgress", function(mission_id, amount)
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  local mission = vRP.query("owl_pass/get_mission_by_id", { id = mission_id })
  if not mission or #mission == 0 then return end
  mission = mission[1]

  local prog = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = mission_id })
  if #prog == 0 then
    vRP.execute("owl_pass/insert_progress", {
      user_id = user_id,
      mission_id = mission_id,
      progress = amount,
      completed = (amount >= mission.objective) and 1 or 0
    })
  else
    local newProgress = prog[1].progress + amount
    local completed = (newProgress >= mission.objective) and 1 or 0
    vRP.execute("owl_pass/update_progress", {
      user_id = user_id,
      mission_id = mission_id,
      progress = newProgress,
      completed = completed
    })
  end
end)

-- ===== Completar missão (dá XP usando AddXP unificado) =====
RegisterNetEvent("owl_pass:completeMission")
AddEventHandler("owl_pass:completeMission", function(mission_id)
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  local mission = vRP.query("owl_pass/get_mission_by_id", { id = mission_id })
  if not mission or #mission == 0 then return end
  mission = mission[1]

  local prog = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = mission_id })
  if #prog > 0 and prog[1].completed == 1 then
    AddXP(user_id, mission.xp_reward)
    vRPclient.notify(src, {"~g~Missão concluída: "..mission.title.." (+"..mission.xp_reward.." XP)"})
  end
end)

-- ===== Recompensas por nível =====
RegisterNetEvent("owl_pass:claimReward")
AddEventHandler("owl_pass:claimReward", function(reward_id)
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  local reward = vRP.query("owl_pass/get_reward", { reward_id = reward_id })
  if not reward or #reward == 0 then return end
  reward = reward[1]

  local claimed = vRP.query("owl_pass/check_claimed_reward", { user_id = user_id, reward_id = reward_id })
  if #claimed > 0 then
    vRPclient.notify(src, {"~r~Você já resgatou essa recompensa!"})
    return
  end

  vRP.execute("owl_pass/insert_claimed_reward", { user_id = user_id, reward_id = reward_id })

  if reward.reward_type == "money" then
    vRP.giveMoney({ user_id, reward.reward_amount })
  elseif reward.reward_type == "item" then
    vRP.giveInventoryItem({ user_id, reward.reward_name, reward.reward_amount, true })
  elseif reward.reward_type == "vehicle" then
    -- adapte ao seu garage
    TriggerEvent("vrp:spawnVehicleForPlayer", user_id, reward.reward_name)
  end

  vRPclient.notify(src, {"~y~Recompensa: "..reward.reward_name.." x"..reward.reward_amount})
end)

-- ===== Hook automático por lógica (incrementa progresso em massa por logic_type)
-- Chame este evento quando acontecer uma ação no servidor: ex: entregou carga, multou player, etc.
RegisterNetEvent("owl_pass:missionActionCompleted")
AddEventHandler("owl_pass:missionActionCompleted", function(logic_type, amount)
  local src = source
  local user_id = vRP.getUserId({ src })
  if not user_id then return end
  ensureUserRow(user_id)

  local amt = tonumber(amount) or 1
  local missions = vRP.query("owl_pass/get_missions_by_logic", { logic_type = logic_type })
  if not missions or #missions == 0 then return end

  for _,m in ipairs(missions) do
    local prog = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = m.id })
    if #prog == 0 then
      vRP.execute("owl_pass/insert_progress", {
        user_id = user_id,
        mission_id = m.id,
        progress = math.min(amt, m.objective),
        completed = (amt >= m.objective) and 1 or 0
      })
    else
      local newProgress = math.min(prog[1].progress + amt, m.objective)
      local completed   = (newProgress >= m.objective) and 1 or 0
      vRP.execute("owl_pass/update_progress", {
        user_id = user_id,
        mission_id = m.id,
        progress = newProgress,
        completed = completed
      })
    end
  end
end)

-- ===== Reset diário simples (00:00)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(60000)
    local hora = os.date("%H:%M")
    if hora == "00:00" then
      vRP.execute("owl_pass/reset_daily", {})
      print("[owl_pass] diárias resetadas.")
      Citizen.Wait(60000)
    end
  end
end)
