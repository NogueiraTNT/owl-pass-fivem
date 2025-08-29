PassConfig = {}

PassConfig.PremiumPrice = 50000
PassConfig.LevelMax = 30
PassConfig.comand = "passe"
PassConfig.XP_BASE = 20.0
PassConfig.XP_MULTIPLIER = 1.2

PassConfig.Missions = {
    -- Missões da Temporada
    Season = {
        xp_reward = 10, -- Recompensa de XP por cada missão da temporada
        list = {
            -- Adicionei 15 missões de exemplo. Você pode customizar os títulos e tipos.
            { id = 1, title = "Faça 50 entregas de caminhoneiro", type = "job_delivery", objective = 50 },
            { id = 2, title = "Venda 20 carros ilegais", type = "ilegal_car_sale", objective = 20 },
            { id = 3, title = "Plante e colha 100 itens de farm", type = "farming", objective = 100 },
            { id = 4, title = "Participe de 10 corridas de rua", type = "racing", objective = 10 },
            { id = 5, title = "Fique 5 horas online no servidor", type = "playtime", objective = 5 },
            { id = 6, title = "Abasteça 30 veículos", type = "refuel", objective = 30 },
            { id = 7, title = "Compre 15 propriedades", type = "property_buy", objective = 15 },
            { id = 8, title = "Pesque 50 peixes raros", type = "fishing", objective = 50 },
            { id = 9, title = "Venda 10 casas", type = "real_estate", objective = 10 },
            { id = 10, title = "Complete 25 contratos de assassino", type = "hitman", objective = 25 },
            { id = 11, title = "Ganhe R$ 1.000.000 em empregos legais", type = "earn_money_legal", objective = 1000000 },
            { id = 12, title = "Gaste R$ 500.000 em roupas", type = "spend_money_clothes", objective = 500000 },
            { id = 13, title = "Faça 40 reparos como mecânico", type = "mechanic", objective = 40 },
            { id = 14, title = "Prenda 20 suspeitos como policial", type = "police", objective = 20 },
            { id = 15, title = "Reanime 15 jogadores como médico", type = "medic", objective = 15 }
        }
    },
    -- Missões Especiais
    Specials = {
        xp_reward = 5, -- Recompensa de XP por cada missão especial
        list = {
            { id = 1, title = "Encontre o tesouro perdido do pirata", type = "event_treasure", objective = 1 },
            { id = 2, title = "Vença o evento de mata-mata especial", type = "event_deathmatch", objective = 1 },
            { id = 3, title = "Capture a bandeira no evento de facção", type = "event_ctf", objective = 1 },
            { id = 4, title = "Seja o último sobrevivente no Battle Royale", type = "event_royale", objective = 1 }
        }
    },
    -- Missões Diárias
    Daily = {
        xp_reward = 20, -- Recompensa de XP por cada missão diária
        list = {
            { id = 1, title = "Faça 5 entregas", type = "job_delivery", objective = 5 },
            { id = 2, title = "Venda 1 carro ilegal", type = "ilegal_car_sale", objective = 1 },
            { id = 3, title = "Fique 1 hora online", type = "playtime", objective = 1 },
            { id = 4, title = "Abasteça 3 veículos", type = "refuel", objective = 3 },
            { id = 5, title = "Pesque 10 peixes", type = "fishing", objective = 10 },
            { id = 6, title = "Ganhe R$ 50.000", type = "earn_money", objective = 50000 },
            { id = 7, title = "Coma e beba 5 vezes", type = "survival", objective = 5 },
            { id = 8, title = "Repare 2 veículos como mecânico", type = "mechanic_repair", objective = 2 },
            { id = 9, title = "Venda 5 itens na sua loja", type = "player_shop_sale", objective = 5 },
            { id = 10, title = "Colete 20 minérios de ferro", type = "mining_iron", objective = 20 },
            { id = 11, title = "Gaste R$ 25.000 em lojas", type = "spend_money", objective = 25000 },
            { id = 12, title = "Roube 3 lojas de conveniência", type = "ilegal_robbery", objective = 3 },
            { id = 13, title = "Fabrique 5 itens", type = "crafting", objective = 5 },
            { id = 14, title = "Transporte 2 passageiros como taxista", type = "taxi_transport", objective = 2 },
            { id = 15, title = "Multa 3 jogadores como policial", type = "police_fine", objective = 3 },
            { id = 16, title = "Cace 5 animais", type = "hunting", objective = 5 },
            { id = 17, title = "Use o caixa eletrônico 2 vezes", type = "atm_use", objective = 2 },
            { id = 18, title = "Envie 10 mensagens no Twitter", type = "social_twitter", objective = 10 },
            { id = 19, title = "Voe por 10 minutos com uma aeronave", type = "flying_time", objective = 10 },
            { id = 20, title = "Visite 3 pontos turísticos", type = "exploration_landmark", objective = 3 },
            { id = 21, title = "Faça um anúncio na OLX", type = "social_olx", objective = 1 },
            { id = 22, title = "Desmanche 1 veículo", type = "ilegal_chopshop", objective = 1 },
            { id = 23, title = "Dirija por 15 quilômetros", type = "driving_distance", objective = 15 },
            { id = 24, title = "Compre uma nova peça de roupa", type = "clothing_buy", objective = 1 },
            { id = 25, title = "Apague 2 incêndios como bombeiro", type = "firefighter", objective = 2 },
            { id = 26, title = "Colete 25 madeiras", type = "lumberjack", objective = 25 },
            { id = 27, title = "Participe de um evento da staff", type = "staff_event", objective = 1 },
            { id = 28, title = "Reanime 2 jogadores", type = "medic", objective = 2 },
            { id = 29, title = "Prenda 3 suspeitos", type = "police", objective = 3 },
            { id = 30, title = "Vença 1 corrida de rua", type = "racing", objective = 1 }
        }
    }
}

