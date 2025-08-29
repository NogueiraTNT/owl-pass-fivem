-- Evento para receber dados do Pass
RegisterNetEvent("owl_pass:receiveData")
AddEventHandler("owl_pass:receiveData", function(saldoPoupanca, nome, nomedois, Pass, carteira, pix, photo, conta) 
    SendNUIMessage({
        type = "updateBankData",
        saldoPoupanca = saldoPoupanca,
        nome = nome,
        nomedois = nomedois,
        Pass = Pass,
        carteira = carteira,
        pix = pix,
        photo = photo,
        conta = conta
    })
end)


-- Extrato Bancario
RegisterNUICallback("extrato", function()
    TriggerServerEvent("owl_pass:extratoBancario")
end)

-- Solicitar Credito
RegisterNUICallback("solicitar", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:solicitarCredito", valor)
    end
end)

-- Pagar Multas
RegisterNUICallback("multas", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:PagarMultas", valor)
    end
end)

RegisterNUICallback("depositar", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:deposit", valor)
    end
end)

RegisterNUICallback("sacar", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:withdraw", valor)
    end
    cb("ok")
end)

RegisterNUICallback("colocar", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:colocar", valor)
    end
end)

RegisterNUICallback("retirar", function(data, cb)
    local valor = tonumber(data.valor)
    if valor and valor > 0 then
        TriggerServerEvent("owl_pass:saquep", valor)
    end
    cb("ok")
end)

RegisterNUICallback('realizarPix', function(data, cb)
    local to = data.targetUserId
    local valor = tonumber(data.valor)
    TriggerServerEvent("owl_pass:pix", to, valor)
end)

RegisterNUICallback('editarPix', function(data, cb)
    local to = data.newPix
    TriggerServerEvent("owl_pass:editarPix", to)
end)

RegisterCommand(PassConfig.comand, function (data, cb)
    SetNuiFocus(true, true)
    SendNUIMessage({type = "openBank"})
    TriggerServerEvent("owl_pass:getData") 
    cb("ok")
end)

-- Comando para fechar o Pass
RegisterNUICallback("fecharPass", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNetEvent("owl_pass:updateData")
AddEventHandler("owl_pass:updateData", function(saldoPoupanca, nome, nomedois, Pass, carteira, pix, photo, conta)
    SendNUIMessage({
        type = "updateBankData",
        saldoPoupanca = saldoPoupanca,
        nome = nome,
        nomedois = nomedois,
        Pass = Pass,
        carteira = carteira,
        pix = pix,
        photo = photo,
        conta = conta
    })
end)

-- Evento para atualizar dados do Pass
RegisterNetEvent("owl_pass:transacao")
AddEventHandler("owl_pass:transacao", function(transacoes)
    SendNUIMessage({
        type = "transacaoBank",
        transacoes = transacoes
    })
end)
