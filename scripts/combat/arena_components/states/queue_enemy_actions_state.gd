class_name QueueEnemyActionsState extends ArenaStateBase

@export var next_state: ArenaStateBase

func enter():
	_queue_enemy_actions()
	parent.change_state(next_state)

func exit():
	pass

func _queue_enemy_actions() -> void:
	
	var alive_enemies = parent.get_alive_enemies()
	var alive_party = parent.get_alive_party()
	
	for enemy in alive_enemies:
		
		var action = BasicAttackAction.create_action(
			"basic enemy attack",
			enemy
		)
		
		var all_skills : Dictionary = CombatantActionStorage.action_dict
		var skill_data : Dictionary = CombatantActionStorage.Action_data
		var enemy_actions : Array = [enemy.action_slot1,enemy.action_slot2,enemy.action_slot3]
		var points : Array[float]
		var highest : float = 0
		var temp_int : int
		
		
		#picking skill to use
		for j in range(enemy_actions.size()):
			
			match enemy_actions[j]:
				CombatantActionStorage.Action.BLANK:
					points.append(0)
				CombatantActionStorage.Action.BASIC_ATTACK:
					for k in range(alive_party.size()):
						if (alive_party[k].health + alive_party[k].base_defense - enemy.base_attack * all_skills[enemy_actions[j]][skill_data.BASE_DAMAGE] <= 0):
							points.append(25)
						else:
							points.append(5)
				CombatantActionStorage.Action.BASIC_HEAL:
					for k in range(alive_enemies.size()):
						if (alive_enemies[k].health - enemy.base_magic * all_skills[enemy_actions[j]][skill_data[skill_data.BASE_HEALING]] <= 0):
							points.append(10)
						else:
							points.append(3)
		
		
		for j in range(enemy_actions.size()):
			
			if (points[j] >= highest):
				highest = points[j]
				temp_int = j
		
		pick_target(all_skills[enemy_actions[temp_int]], action, alive_enemies, alive_party, enemy)




func pick_target(skill: Dictionary, action: CombatantAction, alive_enemies, alive_party, enemy) -> void:
	
	var skill_data : Dictionary = CombatantActionStorage.Action_data
	var points : Array[float]
	var points_total : float = 0
	var percentag : float = 0
	var i : int = 0
	
	action.type = skill[skill_data.TYPE]
	
	match skill[skill_data.TYPE]:
		CombatantActionStorage.Type.NONE:
			print()
		CombatantActionStorage.Type.ATTACK:
			var temp_alive_party = alive_party
			temp_alive_party.shuffle()
			
			for ally in temp_alive_party:
				var hp_done = (ally.health/ally.max_health - int(skill[skill_data.TARGET_LOW_HP])) * -abs(skill[skill_data.HP_WEIGHT]) if skill[skill_data.TARGET_LOW_HP] else abs(skill[skill_data.HP_WEIGHT]) 
				 #change to max attack instead of 99
				var attack_done = (ally.base_attack/99 - int(skill[skill_data.TARGET_LOW_ATTACK])) * -abs(skill[skill_data.ATTACK_WEIGHT]) if skill[skill_data.TARGET_LOW_ATTACK] else abs(skill[skill_data.ATTACK_WEIGHT])
				
				points.append(hp_done + attack_done) 
				
				points_total = points_total + points[i]
				i += 1
			
			var random_number = randf_range(0,points_total)
			for j in range(alive_party.size()):
				percentag += points[j]
				if  random_number <= percentag:
					action.target = temp_alive_party[j]
					parent.action_queue.append(action)
					break 
		
		CombatantActionStorage.Type.HEAL:
			print("heal targeting in progress")
			print(alive_enemies,enemy)
