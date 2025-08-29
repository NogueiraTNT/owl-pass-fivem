RegisterTunnel.sucessoHacker = function()
    local source = source
    local nuser_id = vRP.getUserId(source)
    local allUsers = vRP.query("vrp_pass/get_all_users") 
    local totalRemovido = 0 

    for _, user in ipairs(allUsers) do
        local user_id = user.user_id
        local saldo = vRP.query("vrp_pass/get_savings", { user_id = user_id })

        if saldo and saldo[1] and saldo[1].poupanca and saldo[1].poupanca > 0 then
            local valorRemovido = math.floor(saldo[1].poupanca * 0.07) 
            local novoSaldo = saldo[1].poupanca - valorRemovido

            vRP.execute("vrp_pass/update_savings", { user_id = user_id, poupanca = novoSaldo })
            totalRemovido = totalRemovido + valorRemovido
        end
    end 
    vRPclient._stopAnim(source, false)
    vRP.giveInventoryItem(nuser_id, BankConfig.item, parseInt(totalRemovido), true)
end

RegisterTunnel.startHacker = function() 
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.tryGetInventoryItem(user_id, BankConfig.itemInicio, 1, true, slot) then
        vRPclient._playAnim(source, false, { { "anim@heists@prison_heistig1_p1_guard_checks_bus", "loop" } }, true)  
        return true   
    else
        TriggerClientEvent("Notify", source, "negado", "Você não tem um Keycard.", 6000)
        return false  
    end
end

RegisterTunnel.stopAnim = function() 
    local source = source
    vRPclient._stopAnim(source, false)
end

RegisterTunnel.startPlanejar = function() 
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.tryGetInventoryItem(user_id, BankConfig.itemInicioBanco, 1, true, slot) then
        vRPclient._playAnim(source, false, { { "anim@heists@prison_heistig1_p1_guard_checks_bus", "loop" } }, true) 
        return true   
    else
        TriggerClientEvent("Notify", source, "negado", "Você não tem um Keycard.", 6000)
        return false  
    end
end

RegisterTunnel.chamarPolicia = function(nota)
    local users = vRP.getUsers() 
    local soundCoords = BankConfig.aviso.soundCoords 
    local soundMaxDist = BankConfig.aviso.soundMaxDist 
    local url = string.format("https://translate.google.com/translate_tts?ie=UTF-8&tl=%s&client=tw-ob&q=%s", "pt-BR", 'Atenção todas as unidades, tentativa de assalto a contas poupanças!'..nota)
    
    for user_id, source in pairs(users) do
        local playerSource = vRP.getUserSource(user_id)
        if vRP.hasPermission(user_id, "perm.policia") then 
            TriggerClientEvent("Notify", source, "aviso", nota, 15000) 
            
            -- Iterar sobre as coordenadas
            for _, coords in ipairs(soundCoords) do
                TriggerClientEvent("sjr_me:checkAndPlaySound", playerSource, url, 0.5, coords, soundMaxDist)
            end
            
            TriggerClientEvent("setBlipRoubo", source) 
        end
    end
end



