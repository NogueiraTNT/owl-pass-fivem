RegisterNetEvent("owl_pass:updateProgress", function(mission_id, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local mission = vRP.query("owl_pass/get_mission_by_id", { id = mission_id })[1]
    if not mission then return end

    local progress = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = mission_id })[1]

    if progress then
        -- Atualiza progresso existente
        local newProgress = progress.progress + amount
        local completed = (newProgress >= mission.objective) and 1 or 0
        vRP.execute("owl_pass/update_progress", {
            user_id = user_id,
            mission_id = mission_id,
            progress = newProgress,
            completed = completed
        })
    else
        -- Insere progresso novo
        local completed = (amount >= mission.objective) and 1 or 0
        vRP.execute("owl_pass/insert_progress", {
            user_id = user_id,
            mission_id = mission_id,
            progress = amount,
            completed = completed
        })
    end
end)

--[[ 
    EVENTO: Completar missão e dar XP
    params: mission_id
]]
RegisterNetEvent("owl_pass:completeMission", function(mission_id)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local mission = vRP.query("owl_pass/get_mission_by_id", { id = mission_id })[1]
    local progress = vRP.query("owl_pass/get_player_progress", { user_id = user_id, mission_id = mission_id })[1]

    if mission and progress and progress.completed == 1 and progress.claimed == 0 then
        -- Marca como resgatada
        vRP.execute("owl_pass/update_progress", {
            user_id = user_id,
            mission_id = mission_id,
            progress = progress.progress,
            completed = 1
        })

        -- Atualiza XP do jogador
        local userPass = vRP.query("owl_pass/get_user_ranking", { user_id = user_id })[1]
        if userPass then
            local newXP = userPass.xp + mission.xp_reward
            local newLevel = math.floor(newXP / 1000) + 1 -- exemplo: 1000xp por level
            vRP.execute("owl_pass/update_user_xp_level", {
                user_id = user_id,
                xp = newXP,
                level = newLevel
            })
        end
    end
end)

--[[ 
    EVENTO: Resgatar recompensa do passe
    params: reward_id
]]
RegisterNetEvent("owl_pass:claimReward", function(reward_id)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local reward = vRP.query("owl_pass/get_reward", { reward_id = reward_id })[1]
    if not reward then return end

    local claimed = vRP.query("owl_pass/check_claimed_reward", {
        user_id = user_id,
        reward_id = reward_id
    })[1]

    if not claimed then
        -- Marca como coletada
        vRP.execute("owl_pass/insert_claimed_reward", {
            user_id = user_id,
            reward_id = reward_id
        })

        -- Dá a recompensa de fato
        if reward.reward_type == "money" then
            vRP.giveMoney(user_id, reward.reward_amount)
        elseif reward.reward_type == "item" then
            vRP.giveInventoryItem(user_id, reward.reward_name, reward.reward_amount, true)
        elseif reward.reward_type == "vehicle" then
            -- precisa de integration com garage do vRP
            TriggerEvent("nation_garages:addVehicle", user_id, reward.reward_name, 1)
        else
            print("[OWL_PASS] Tipo de recompensa não suportado: "..reward.reward_type)
        end
    end
end)
