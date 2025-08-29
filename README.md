# Passe de Batalha (vRP) – Documentação de Uso

## 1. Estrutura do Sistema

O Passe de Batalha é dividido em:

- **Banco de Dados** (tabelas para jogadores, missões, progresso e recompensas)
- **Server** (eventos, cálculos de XP/level, sincronização de missões e recompensas)
- **Client** (interface NUI, comandos e callbacks)
- **Config** (curva de progressão e catálogo de missões)

---

## 2. Banco de Dados

### Tabelas principais

- `owl_pass`: dados de cada jogador (user_id, tipo de passe, XP e nível).
- `owl_pass_missions`: catálogo de missões.
- `owl_pass_player_progress`: progresso individual dos jogadores em cada missão.
- `owl_pass_rewards`: catálogo de recompensas por nível.
- `owl_pass_claimed_rewards`: histórico de recompensas já resgatadas.

### Reset automático

Às 00:00, todas as missões **diárias** têm progresso resetado.

---

## 3. Configuração (config/config.lua)

- `PassConfig.LevelMax` → nível máximo.
- `PassConfig.XP_BASE` / `XP_MULTIPLIER` → curva de XP/level.
- `PassConfig.comand` → comando para abrir o passe.
- `PassConfig.Missions` → catálogo de missões (Daily, Season, Specials).

> O sistema sincroniza automaticamente missões definidas no `PassConfig` com o banco de dados.

---

## 4. Eventos Principais

### Client → Server

- `owl_pass:requestRanking` → pede ranking e dados do jogador.
- `owl_pass:requestMissions` (missionType) → pede lista de missões + progresso.
- `owl_pass:updateProgress` (mission_id, amount) → atualiza progresso de uma missão.
- `owl_pass:completeMission` (mission_id) → completa missão e dá XP.
- `owl_pass:claimReward` (reward_id) → resgata recompensa.

### Server → Client

- `owl_pass:sendRanking` → devolve ranking + dados do jogador.
- `owl_pass:sendMissions` → devolve missões + progresso do jogador.
- `owl_pass:updateUIData` → atualiza a interface após XP ou level mudar.

### Server (interno)

- `owl_pass:missionActionCompleted` (logic_type, amount) → incrementa progresso automaticamente em todas as missões que usam esse `logic_type`.

---

## 5. Fluxo de Uso

1. Jogador digita `/passe` → abre NUI.
2. Client dispara `requestRanking` → Server responde `sendRanking`.
3. Jogador abre aba de missões → Client dispara `requestMissions` → Server responde `sendMissions`.
4. Ao realizar ações no servidor, chame `missionActionCompleted` com o `logic_type` correspondente.
5. Quando objetivo for atingido, jogador pode clicar para **completar missão** → ganha XP.
6. Quando atingir um nível com recompensa, jogador pode clicar para **resgatar** → item/dinheiro/veículo é entregue.

---

## 6. Progressão de XP / Nível

- Calculada unicamente pela função `AddXP()`.
- Fórmula: `XP Necessário = floor(XP_BASE * (level ^ XP_MULTIPLIER))`
- `LevelMax` define limite.
- Notificações informam ganho de XP e level up.

---

## 7. Hooks (Integração com outros sistemas)

Para conectar missões às ações do servidor:

```lua
TriggerEvent("owl_pass:missionActionCompleted", "<logic_type>", amount)
```

Exemplos:

- Caminhoneiro → `"job_delivery", 1`
- Polícia → `"police", 1`
- Pesca → `"fishing", 1`
- Corrida → `"racing", 1`

---

## 8. Checklist de Teste

- [ ] Ranking abre e mostra top 6.
- [ ] Jogador novo recebe linha automática em `owl_pass`.
- [ ] Missões aparecem zeradas no primeiro acesso.
- [ ] `missionActionCompleted` incrementa progresso certo.
- [ ] Completar missão dá XP corretamente.
- [ ] Level up dispara notify.
- [ ] Recompensa não pode ser resgatada duas vezes.
- [ ] Reset diário zera apenas missões Daily.
- [ ] Integração de veículos adaptada para sua garagem.

---

## 9. Erros Comuns

- **query não encontrada** → faltou `prepare` no server.
- **XP sobe mas level não** → outra lógica de level rodando; só use `AddXP()`.
- **Missão não progride** → `logic_type` não bate com o da missão.
- **Resete diário não rodou** → hora do host diferente de 00:00.

---

## 10. Resumo

O sistema garante:

- Ranking de XP/level.
- Missões diárias, sazonais e especiais.
- Progresso automático por `logic_type`.
- Recompensas únicas por nível.
- Reset diário automático.
- Fácil integração com sistemas existentes via evento `missionActionCompleted`.
