function atulizar(source,user_id)  
    local banco = vRP.getBankMoney(user_id)
    local carteira = vRP.getMoney(user_id)
    local identity = vRP.getUserIdentity(user_id)
    local nome = identity.nome
    local nomedois = identity.sobrenome
    local current_coins = vRP.query("vrp_pass/get_coins", {user_id = user_id})
    local coins = parseInt(current_coins[1].vip)
    local saldo = vRP.query("vrp_pass/get_savings", {user_id = user_id})
    local saldoPoupanca = parseInt(saldo[1].poupanca) 
    local multas = vRP.getUData(user_id,"vRP:multas")
    local mymultas = json.decode(multas) or 0
    local user_pix = vRP.query("vrp_pass/get_pix_user", {user_id = user_id})
    local pix = user_pix[1].chavePix
    local user_photo = vRP.query("vrp_pass/get_photo", {user_id = user_id})
    local photo = ''
    if user_photo[1] == nil then
        photo = 'https://require.store/img/profile.png'
    else         
        photo = user_photo[1].avatarURL
    end    

    TriggerClientEvent("require_bank:updateData", source, saldoPoupanca, nome, nomedois, banco, carteira, pix, photo, conta)
end

RegisterServerEvent("require_bank:extratoBancario")
AddEventHandler("require_bank:extratoBancario", function()
    local source = source
    local user_id = vRP.getUserId(source)
    local transacoes = vRP.query("vrp_pass/get_transacoes", {user_id = user_id})

    TriggerClientEvent("require_bank:transacao", source, transacoes)
    
end)

RegisterServerEvent("require_bank:getData")
AddEventHandler("require_bank:getData", function()
    local source = source
    local user_id = vRP.getUserId(source)
    local banco = vRP.getBankMoney(user_id)
    local carteira = vRP.getMoney(user_id)
	local identity = vRP.getUserIdentity(user_id)
    local nome = identity.nome
	local nomedois = identity.sobrenome
    local current_coins = vRP.query("vrp_pass/get_coins", {user_id = user_id})
    local coins = parseInt(current_coins[1].vip)
    local saldo = vRP.query("vrp_pass/get_savings", {user_id = user_id})
    local saldoPoupanca = parseInt(saldo[1].poupanca)    
    local multas = vRP.getUData(user_id,"vRP:multas")
    local mymultas = json.decode(multas) or 0
    local user_pix = vRP.query("vrp_pass/get_pix_user", {user_id = user_id})
    local pix = user_pix[1].chavePix
    local user_photo = vRP.query("vrp_pass/get_photo", {user_id = user_id})
    local photo = ''
    if user_photo[1] == nil then
        photo = 'https://require.store/img/profile.png'
    else         
        photo = user_photo[1].avatarURL
    end
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id})  
    local conta = ''      
    if query and #query > 0 then            
        conta = 'true'
    else 
        conta = 'false' 
    end

    TriggerClientEvent("require_bank:receiveData", source, saldoPoupanca, nome, nomedois, banco, carteira, pix, photo, conta)
    
end)

RegisterServerEvent("require_bank:editarPix")
AddEventHandler("require_bank:editarPix", function(chavePix)
    local source = source
    local user_id = vRP.getUserId(source)

    vRP.execute("vrp_pass/set_pix", {user_id = user_id, chavePix = chavePix})
    atulizar(source,user_id)
end)

local processingM = {}
-- Função Pagar Multas
RegisterServerEvent("require_bank:PagarMultas")
AddEventHandler("require_bank:PagarMultas", function(valor)
    local source = source
    local user_id = vRP.getUserId(source) 
    local multas = vRP.getUData(user_id,"vRP:multas")
    local mymultas = json.decode(multas)

    -- Controle para evitar processamento duplicado
    if processingM[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingM[user_id] = true 
    
    if valor < vRP.getBankMoney(user_id) then  
        if valor > mymultas then
            TriggerClientEvent("Notify",source,"negado","Você não pode pagar uma multa maior do que deve")
        else

            poupancaBankMoney(user_id, tonumber(valor))
            local new_multas = mymultas - valor            
		    vRP.setUData(user_id,"vRP:multas",json.encode(new_multas))
            vRP.execute("vrp_pass/add_historico", {
                user_id = user_id,
                type = 'multa paga',
                amount = tonumber(valor)
            })
    
            TriggerClientEvent("Notify",source,"sucesso","Você paggou <b>"..valor.."  de Multa</b>.")

        end
    
    else
        TriggerClientEvent("Notify",source,"negado"," insuficiente na Conta Bancaria")
    end

    

    atulizar(source,user_id)
    
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingM[user_id] = nil -- Libera o processamento para o próximo uso
end)

local processingD = {}
-- Função de Depositar
RegisterServerEvent("require_bank:deposit")
AddEventHandler("require_bank:deposit", function(valor)
    local source = source
    local user_id = vRP.getUserId(source)

    -- Controle para evitar processamento duplicado
    if processingD[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingD[user_id] = true 

    if vRP.withdrawCash(user_id,valor) then
        TriggerClientEvent("Notify",source,"negado"," insuficiente")
    else
        vRP.tryDeposit(user_id, tonumber(valor))
        vRP.execute("vrp_pass/add_historico", {
            user_id = user_id,
            type = 'deposito',
            amount = tonumber(valor)
        })

        TriggerClientEvent("Notify",source,"sucesso","Você Despositou <b>"..valor.." </b>.")
    end

    

    atulizar(source,user_id)
    
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingD[user_id] = nil -- Libera o processamento para o próximo uso
end)

local processingDP = {}
-- Função de Depositar na Poupança
RegisterServerEvent("require_bank:colocar")
AddEventHandler("require_bank:colocar", function(valor)
    local source = source
    local user_id = vRP.getUserId(source)
    local saldoBanco = vRP.getBank(user_id)
    local saldo = vRP.query("vrp_pass/get_savings", {user_id = user_id})
    local saldoPoupanca = parseInt(saldo[1].poupanca)

    -- Controle para evitar processamento duplicado
    if processingDP[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingDP[user_id] = true 

    if valor > saldoBanco then
        TriggerClientEvent("Notify",source,"negado"," insuficiente na sua Conta")
    else

        local soma = saldoPoupanca + tonumber(valor)
        vRP.execute("vrp_pass/set_poupanca", { user_id = user_id, poupanca = soma })
        vRP.delBank(user_id,tonumber(valor))

        vRP.execute("vrp_pass/add_historico", {
            user_id = user_id,
            type = 'deposito poupanca',
            amount = tonumber(valor)
        })

        TriggerClientEvent("Notify",source,"sucesso","Você Despositou <b>"..valor.." </b> na sua Poupança.")
    end

    

    atulizar(source,user_id)
    
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingDP[user_id] = nil -- Libera o processamento para o próximo uso
end)

local processingS = {}
-- Função de saque
RegisterServerEvent("require_bank:withdraw")
AddEventHandler("require_bank:withdraw", function(valor)
    local source = source
    local user_id = vRP.getUserId(source)

    -- Controle para evitar processamento duplicado
    if processingS[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingS[user_id] = true 

    if valor > vRP.getBank(user_id) then
        TriggerClientEvent("Notify",source,"negado"," insuficiente")
    else
        vRP.withdrawCash(user_id,tonumber(valor))
        vRP.execute("vrp_pass/add_historico", {
            user_id = user_id,
            type = 'saque',
            amount = tonumber(valor)
        })

        TriggerClientEvent("Notify",source,"sucesso","Você Sacou <b>"..valor.." </b>.")
    end    

    atulizar(source,user_id)
    
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingS[user_id] = nil -- Libera o processamento para o próximo uso
end)

local processingSP = {}
-- Função de saque da poupanca
RegisterServerEvent("require_bank:saquep")
AddEventHandler("require_bank:saquep", function(valor)
    local source = source
    local user_id = vRP.getUserId(source)
    local banco = vRP.getBank(user_id)
    local saldo = vRP.query("vrp_pass/get_savings", {user_id = user_id})
    local saldoPoupanca = parseInt(saldo[1].poupanca)

    -- Controle para evitar processamento duplicado
    if processingSP[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingSP[user_id] = true 

    if valor > saldoPoupanca then
        TriggerClientEvent("Notify",source,"negado"," insuficiente na Poupança")
    else        
        local saldoPoupanca = saldo[1].poupanca        
        local banco = vRP.getBankMoney(user_id) 
        local sub = saldoPoupanca - tonumber(valor)
        vRP.execute("vrp_pass/set_poupanca", { user_id = user_id, poupanca = sub })
        vRP.addBank(user_id,tonumber(valor))
        vRP.execute("vrp_pass/add_historico", {
            user_id = user_id,
            type = 'saque poupanca',
            amount = tonumber(valor)
        })

        TriggerClientEvent("Notify",source,"sucesso","Você Retirou <b>"..valor.." </b> da conta Poupança.")
    end

    atulizar(source,user_id)
    
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingSP[user_id] = nil -- Libera o processamento para o próximo uso
end)

local processingP = {}
RegisterServerEvent('require_bank:pix')
AddEventHandler('require_bank:pix', function(chavePix,valor)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id) 
    local nplayer = vRP.query("vrp_pass/get_pix", {chavePix = chavePix})
	local nuser_id = nplayer[1].id 
    local source2 = vRP.getUserSource(nuser_id)
	local identitynu = vRP.getUserIdentity(nuser_id)
	local banco = 0

    -- Controle para evitar processamento duplicado
    if processingP[user_id] then
        print("Processamento já em andamento para o usuário " .. user_id)
        return
    end

    processingP[user_id] = true

	if nuser_id == nil then
		TriggerClientEvent("Notify",source,"negado","Passaporte inválido ou indisponível.")
	else
		if nuser_id == user_id then
			TriggerClientEvent("Notify",source,"negado","Você não pode transferir dinheiro para sí mesmo.")	
		else
			local banco = vRP.getBank(user_id)
			local banconu = vRP.getBank(nuser_id)
			
			if banco <= 0 or banco < tonumber(valor) or tonumber(valor) <= 0 then
				TriggerClientEvent("Notify",source,"negado"," Insuficiente")
			else
				vRP.delBank(user_id,tonumber(valor))
				vRP.addBank(nuser_id,tonumber(valor))
                vRP.execute("vrp_pass/add_historico", {
                    user_id = user_id,
                    type = 'pix',
                    amount = valor
                })
                
                atulizar(source,user_id)            
				TriggerClientEvent("Notify",source2,"sucesso","<b>"..identity.nome.." "..identity.sobrenome.."</b> depositou <b>"..valor.." </b> na sua conta.")
				TriggerClientEvent("Notify",source,"sucesso","Você transferiu <b>"..valor.." </b> para conta de <b>"..identitynu.nome.." "..identitynu.sobrenome.."</b>.")
			end
		end
    end

    -- Limpa o controle de processamento após a transação
    Citizen.Wait(100) -- Pequeno delay para evitar duplicidade rápida
    processingP[user_id] = nil
end)

-- Função para solicitar crédito
RegisterServerEvent("require_bank:solicitarCredito")
AddEventHandler("require_bank:solicitarCredito", function(valor)
    local source = source
    local user_id = vRP.getUserId(source)    

    vRP.giveInventoryItem(parseInt(user_id), 'cartao-debito', 1) -- apenas se dê tudo certo
    
    -- local salario = vRP.getSData({user_id, "vRP:salary"}) or 0  -- Exemplo de como obter salário

    -- if salario >= Config.MinSalarioCredito then
    --     if valor <= Config.CreditoMaximo then
    --         vRP.giveBankMoney({user_id, valor})
    --         MySQL.Async.execute("INSERT INTO bank_history (user_id, type, amount, date) VALUES (@user_id, 'credito', @amount, NOW())", {
    --             ['@user_id'] = user_id,
    --             ['@amount'] = valor
    --         })
    --         TriggerClientEvent("require_bank:creditoSuccess", source, valor)
    --     else
    --         TriggerClientEvent("require_bank:creditoFail", source, "Valor de crédito acima do limite.")
    --     end
    -- else
    --     TriggerClientEvent("require_bank:creditoFail", source, "Salário insuficiente para crédito.")
    -- end
end)

Citizen.CreateThread(function()
    local rendimento = BankConfig.Rendimento

    while true do
        Citizen.Wait(21600000) -- A cada 24 horas (86400000 milissegundos)

        local allUsers = vRP.query("vrp_pass/get_all_users")
        for _, user in ipairs(allUsers) do
            local user_id = user.user_id
            local saldo = vRP.query("vrp_pass/get_savings", { user_id = user_id })

            if saldo and #saldo > 0 then
                local saldoPoupanca = saldo[1].poupanca
                local rendimentoAplicado = saldoPoupanca * rendimento
                local novoSaldo = saldoPoupanca + rendimentoAplicado
                vRP.execute("vrp_pass/set_poupanca", { user_id = user_id, poupanca = novoSaldo })
            end
        end
    end
end)

-- vRP.getInventoryItemAmount(user_id, 'tablet')
RegisterTunnel.statusCartao = function()
	local source = source
	local user_id = vRP.getUserId(source)
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id})  
    if query and #query > 0 then
        if query[1].status == 'bloqueado' then
            return false
        elseif query[1].status == 'desbloqueado' then
            return true
        end
    end
end

RegisterTunnel.mudarCartao = function(mudarStatus)
	local source = source
	local user_id = vRP.getUserId(source)
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id})    
    if vRP.getInventoryItemAmount(user_id, 'cartao-debito') >= 1 then     
        if query and #query > 0 then
            if query[1].status == 'bloqueado' then
                TriggerClientEvent("Notify",source,"sucesso","Você desbloqueou o seu cartão com Sucesso!",5000)
                vRP.execute("vrp_pass/up_status_cartao", {status = 'desbloqueado', user_id = user_id}) 
            elseif query[1].status == 'desbloqueado' then
                TriggerClientEvent("Notify",source,"sucesso","Você bloqueou o seu cartão com Sucesso!",5000)
                vRP.execute("vrp_pass/up_status_cartao", {status = 'bloqueado', user_id = user_id}) 
            end
        end
    end
end

RegisterTunnel.segundaVia = function()
	local source = source
	local user_id = vRP.getUserId(source)
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id})    
    if vRP.getInventoryItemAmount(user_id, 'cartao-debito') == 0 then     
        if query and #query > 0 then            
            vRP.giveInventoryItem(user_id, 'cartao-debito', 1, true)
            TriggerClientEvent("Notify",source,"sucesso","Você recebeu a segunda via do seu cartão!",5000)
        end
    end
end

RegisterServerEvent("require_bank:contas")
AddEventHandler("require_bank:contas", function(valor, senha)
    local source = source
    local user_id = vRP.getUserId(source)  
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id})    
    if vRP.getInventoryItemAmount(user_id, 'cartao-debito') == 0 then     
        if query and #query > 0 then  
            TriggerClientEvent("Notify",source,"sucesso","Você editou seus dados!",5000)          
            vRP.execute("vrp_pass/update_conta", {
                user_id = user_id, 
                login = valor, 
                senha = senha
            })
        else           
            vRP.giveInventoryItem(user_id, 'cartao-debito', 1, true)
            TriggerClientEvent("Notify",source,"sucesso","Você recebeu o cartão da sua conta!",5000)
            vRP.execute("vrp_pass/insert_conta", {
                user_id = user_id, 
                login = valor, 
                senha = senha
            })            
        end
    else     
        if query and #query > 0 then  
            TriggerClientEvent("Notify",source,"sucesso","Você editou seus dados!",5000)          
            vRP.execute("vrp_pass/update_conta", {
                user_id = user_id, 
                login = valor, 
                senha = senha
            })
        end 
    end
end)

local usersLogged = {}
local timeout = 300 -- Tempo em segundos antes do logout automático (5 minutos)

RegisterServerEvent("require_bank:login")
AddEventHandler("require_bank:login", function(login, senha)
    local source = source
    local user_id = vRP.getUserId(source) -- Obtém o ID do usuário no sistema vRP
    local query = vRP.query("vrp_pass/get_status_cartao", {user_id = user_id}) 
    if user_id then
        local result = vRP.query("vrp_pass/get_conta", {
            login = login,
            senha = senha
        })           
        if vRP.getInventoryItemAmount(user_id, 'cartao-debito') >= 1 then  
            if #result > 0 then
                if result[1].user_id == user_id then 
                    if result[1].status == 'desbloqueado' then
                        usersLogged[user_id] = { time = os.time(), source = source }
                        local banco = vRP.getBankMoney(result[1].user_id)
                        local carteira = vRP.getMoney(result[1].user_id)
                        local identity = vRP.getUserIdentity(result[1].user_id)
                        local nome = identity.nome
                        local nomedois = identity.sobrenome
                        local saldo = vRP.query("vrp_pass/get_savings", {user_id = result[1].user_id})
                        local saldoPoupanca = parseInt(saldo[1].poupanca)                      
                        TriggerClientEvent("require_bank:loginSuccess", source, saldoPoupanca, nome, nomedois, banco, carteira)
                    elseif result[1].status == 'bloqueado' then 
                        TriggerClientEvent("require_bank:loginFail", source)                
                        TriggerClientEvent("Notify",source,"negado","Você não pode acessar uma conta bloqueda!",5000)
                    end
                else
                    TriggerClientEvent("require_bank:loginFail", source)
                    TriggerClientEvent("Notify",source,"negado","Você não pode acessar essa conta com essa cartão!",5000)
                end
            else
                TriggerClientEvent("require_bank:loginFail", source)
            end
        elseif vRP.getInventoryItemAmount(user_id, 'cartao-clonado') >= 1 then
            -- ainda vou fazer essa logica
        end
    end
end)

-- Deslogar automaticamente após tempo de inatividade
CreateThread(function()
    while true do
        Wait(60000) -- Verifica a cada 60 segundos
        local currentTime = os.time()
        for user_id, data in pairs(usersLogged) do
            if (currentTime - data.time) >= timeout then
                usersLogged[user_id] = nil
                TriggerClientEvent("require_bank:logout", data.source)
            end
        end
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id and usersLogged[user_id] then
        usersLogged[user_id] = nil
    end
end)

RegisterServerEvent("require_bank:updateActivity")
AddEventHandler("require_bank:updateActivity", function()
    local src = source
    local user_id = vRP.getUserId(src)
    if user_id and usersLogged[user_id] then
        usersLogged[user_id].time = os.time()
    end
end)