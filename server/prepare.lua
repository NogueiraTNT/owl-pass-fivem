-- server/prepare.lua

-- RANKING / XP
vRP.prepare("owl_pass/get_ranking",
  "SELECT user_id, xp, level FROM owl_pass ORDER BY level DESC, xp DESC LIMIT 6")
vRP.prepare("owl_pass/get_user_ranking",
  "SELECT user_id, pass, xp, level FROM owl_pass WHERE user_id = @user_id")
vRP.prepare("owl_pass/insert_user_row",
  "INSERT INTO owl_pass (user_id, pass, xp, level) VALUES (@user_id, 'STANDARD', 0, 0)")
vRP.prepare("owl_pass/update_user_xp_level",
  "UPDATE owl_pass SET xp = @xp, level = @level WHERE user_id = @user_id")
vRP.prepare("owl_pass/get_all_players_ordered",
  "SELECT user_id FROM owl_pass ORDER BY level DESC, xp DESC")

-- MISSÕES (catálogo + progresso)
vRP.prepare("owl_pass/get_mission_by_id",
  "SELECT * FROM owl_pass_missions WHERE id = @id")
vRP.prepare("owl_pass/get_missions_by_logic",
  "SELECT * FROM owl_pass_missions WHERE logic_type = @logic_type")
vRP.prepare("owl_pass/get_mission_by_logic_type",
  "SELECT id FROM owl_pass_missions WHERE logic_type = @logic_type")
vRP.prepare("owl_pass/insert_mission",
  "INSERT INTO owl_pass_missions (mission_type, title, logic_type, objective, xp_reward, reward_pool) VALUES (@mission_type, @title, @logic_type, @objective, @xp_reward, @reward_pool)")

vRP.prepare("owl_pass/get_player_progress",
  "SELECT * FROM owl_pass_player_progress WHERE user_id = @user_id AND mission_id = @mission_id")
vRP.prepare("owl_pass/insert_progress",
  "INSERT INTO owl_pass_player_progress (user_id, mission_id, progress, completed, claimed) VALUES (@user_id, @mission_id, @progress, @completed, 0)")
vRP.prepare("owl_pass/update_progress",
  "UPDATE owl_pass_player_progress SET progress = @progress, completed = @completed WHERE user_id = @user_id AND mission_id = @mission_id")
vRP.prepare("owl_pass/reset_daily",
  "UPDATE owl_pass_player_progress SET progress = 0, completed = 0, claimed = 0 WHERE mission_id IN (SELECT id FROM owl_pass_missions WHERE mission_type = 'Daily')")

-- RECOMPENSAS
vRP.prepare("owl_pass/get_reward",
  "SELECT * FROM owl_pass_rewards WHERE id = @reward_id")
vRP.prepare("owl_pass/check_claimed_reward",
  "SELECT * FROM owl_pass_claimed_rewards WHERE user_id = @user_id AND reward_id = @reward_id")
vRP.prepare("owl_pass/insert_claimed_reward",
  "INSERT INTO owl_pass_claimed_rewards (user_id, reward_id, claimed) VALUES (@user_id, @reward_id, 1)")
