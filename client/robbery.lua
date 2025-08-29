local statusGame = 0
local statusBanco = 0

RegisterNetEvent("require_bank:startHacker")
AddEventHandler("require_bank:startHacker", function()
    if statusGame == 0 then
        if Remote.startHacker() then
            Remote.chamarPolicia('Primeiro Hacker iniciado.')
            TriggerEvent("require_bank:game1", 1)
        end
    elseif statusGame == 1 then
        if Remote.startHacker() then
            Remote.chamarPolicia('Segundo Hacker iniciado.')
            TriggerEvent("require_bank:game2", 2)
        end
    elseif statusGame == 2 then
        if Remote.startHacker() then
            Remote.chamarPolicia('Terceiro Hacker iniciado.')
            TriggerEvent("require_bank:game3", 3)
        end
    else
        Remote.chamarPolicia('Todas as Contas poupanças foram Hakeadas.')
        Remote.sucessoHacker()
    end
end)

RegisterNetEvent("require_bank:startBank")
AddEventHandler("require_bank:startBank", function()
    if statusBanco == 0 then
        if Remote.startPlanejar() then
            TriggerEvent("require_bank:game4", 1)
        end
    -- elseif statusBanco == 1 then
    --     if Remote.startHacker() then
    --         TriggerEvent("require_bank:game2", 2)
    --     end
    -- elseif statusBanco == 2 then
    --     if Remote.startHacker() then
    --         TriggerEvent("require_bank:game3", 3)
    --     end
    -- else
    --     Remote.sucessoHacker()
    end
end)

RegisterNetEvent("require_bank:game1")
AddEventHandler("require_bank:game1", function(passo)
    exports['boii_minigames']:chip_hack({
        style = 'default',
        loading_time = 8000,
        chips = 2,
        timer = 30000
    }, function(success)
        if success then
            Remote.stopAnim()
            statusGame = passo
        else
            Remote.stopAnim()
            statusGame = 0
        end
    end)
end)

RegisterNetEvent("require_bank:game2")
AddEventHandler("require_bank:game2", function(passo)
    local numero = math.random(1, 5)
    exports['boii_minigames']:anagram({
        style = 'default',
        loading_time = 5000,
        difficulty = numero,
        guesses = 5,
        timer = 30000
    }, function(success)
        if success then
            Remote.stopAnim()
            statusGame = passo
        else
            Remote.stopAnim()
            statusGame = 0
        end
    end)
end)

RegisterNetEvent("require_bank:game3")
AddEventHandler("require_bank:game3", function(passo)
    local numero = math.random(1, 5)
    exports['boii_minigames']:pincode({
        style = 'default', 
        difficulty = numero, 
        guesses = 10 
    }, function(success) 
        if success then
            Remote.stopAnim()
            statusGame = passo
        else
            Remote.stopAnim()
            statusGame = 0
        end
    end)
end)


RegisterNetEvent("require_bank:game4")
AddEventHandler("require_bank:game4", function(passo)
    local numero = math.random(1, 5)    
    exports['boii_minigames']:button_mash({
        style = 'default', -- Style template
        difficulty = numero -- Difficulty; increasing the difficulty decreases the amount the notch increments on each keypress making the game harder to complete
    }, function(success) -- Game callback
        if success then
            Remote.stopAnim()
            statusBanco = passo
            TriggerEvent("Notify", "sucesso", "Arrombe a porta!.", 6000)
        else
            Remote.stopAnim()
            statusBanco = 0
        end
    end)
end)

RegisterNetEvent("setBlipRoubo")
AddEventHandler("setBlipRoubo", function()
    local blip = AddBlipForCoord(1275.7,-1710.54,54.76) 
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1)
    PulseBlip(blip)

    Citizen.SetTimeout(120000, function()
        RemoveBlip(blip)
    end)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 100
        local ped = PlayerPedId()
        local cds = GetEntityCoords(ped)
        local isInVehicle = IsPedInAnyVehicle(ped, false)

        for _, bancoCoords in ipairs(BankConfig.cdsHacker) do
            local dist = #(cds - bancoCoords)

            if dist < 10.0 then
                sleep = 3
                if dist <= 2.0 and not isInVehicle then
                    DrawText3D(bancoCoords.x, bancoCoords.y, bancoCoords.z, "Pressione ~r~[E]~w~ para iniciar o ~g~Hacker")
                    if IsControlJustPressed(0, BankConfig.button) then
                        TriggerEvent("require_bank:startHacker")
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 100
        local ped = PlayerPedId()
        local cds = GetEntityCoords(ped)
        local isInVehicle = IsPedInAnyVehicle(ped, false)

        for _, bancoCoords in ipairs(BankConfig.cdsBancoCentral) do
            local dist = #(cds - bancoCoords)

            if dist < 10.0 then
                sleep = 3
                if dist <= 2.0 and not isInVehicle then
                    DrawText3D(bancoCoords.x, bancoCoords.y, bancoCoords.z, "Pressione ~r~[E]~w~ para começar o planejamento do ~g~Roubo")
                    if IsControlJustPressed(0, BankConfig.button) then
                        TriggerEvent("require_bank:startBank")
                        -- for _, porta in pairs(BankConfig.portas) do
                        --     trancarPorta(porta.model, porta.coords, true) -- Tranca todas no início
                        -- end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    for _, porta in pairs(BankConfig.portas) do
        trancarPorta(porta.model, porta.coords, true)
    end
end)
