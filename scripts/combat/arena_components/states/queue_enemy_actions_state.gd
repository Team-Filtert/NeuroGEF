class_name QueueEnemyActionsState
extends ArenaStateBase

@export var next_state: ArenaStateBase

func enter():
	_queue_enemy_actions()
	parent.change_state(next_state)

func exit():
	pass

func _queue_enemy_actions() -> void:
	var alive_enemies = parent.get_alive_enemies()

	for enemy in alive_enemies:
		
		var action = pick_action(enemy)

		parent.submit_action(action)


func data_to_calculated_points(input_data: Array, points_calculator: Callable):
	return input_data.map(points_calculator)

func pick_action(source: Combatant) -> CombatantAction:
	var alive_enemies = parent.get_alive_enemies()
	var alive_party = parent.get_alive_party()

	var action = BasicAttackAction.create_action(
		"basic enemy attack",
		source
	)
	
	# Info about all skills that contains weights and all
	# TODO: get weights from current action
	var all_skills : Dictionary = CombatantActionStorage.action_dict
	# All skills of current enemy that we choose of
	var enemy_actions : Array = [source.action_slot1,source.action_slot2,source.action_slot3]

	var vulnerability_criteria = func(cur_target: Combatant):
		return cur_target.health + cur_target.base_defense - source.base_attack <= 0
	
	var heal_criteria = func(cur_target: Combatant):
		return cur_target.health - source.base_magic <= 0
	
	# picking skill to use
	for j in range(enemy_actions.size()):
		
		match enemy_actions[j]:
			CombatantActionStorage.Action.BLANK:
				# var points = [0]
				pass
			CombatantActionStorage.Action.BASIC_ATTACK:
				var points = data_to_calculated_points(alive_party, func(pm: Combatant):
					if (vulnerability_criteria.call(pm)):
						return 25
					else:
						return 5
				)
	
				var highest = points.max()
				var temp_int = points.find(highest)
				
				action.target = pick_target(
					all_skills[enemy_actions[temp_int]],
					action,
					alive_party,
					source
				)
			CombatantActionStorage.Action.BASIC_HEAL:
				var points = data_to_calculated_points(alive_enemies, func(enemy: Combatant):
					if (heal_criteria.call(enemy)):
						return 10
					else:
						return 3
				)
	
				var highest = points.max()
				var temp_int = points.find(highest)
				
				action.target = pick_target(
					all_skills[enemy_actions[temp_int]],
					action,
					alive_enemies,
					source
				)
		
	
	return action


func pick_target(skill: Dictionary, action: CombatantAction, targets: Array, source) -> Combatant:
	
	var skill_data := CombatantActionStorage.Action_data

	var result_target: Combatant

	var data_to_choose_from = targets
	data_to_choose_from.shuffle()
	
	action.type = skill[skill_data.TYPE]
	
	match skill[skill_data.TYPE]:
		CombatantActionStorage.Type.NONE:
			print()
		CombatantActionStorage.Type.ATTACK:
			var points = data_to_calculated_points(data_to_choose_from, func(target: Combatant):
				var hp_done = (
					float(target.health)/target.max_health - \
					int(skill[skill_data.TARGET_LOW_HP])) * -abs(skill[skill_data.HP_WEIGHT]) \
					if skill[skill_data.TARGET_LOW_HP] else abs(skill[skill_data.HP_WEIGHT])
				
				 #change to max attack instead of 99
				var attack_done = (
					float(target.base_attack)/99 - int(skill[skill_data.TARGET_LOW_ATTACK])) * \
					-abs(skill[skill_data.ATTACK_WEIGHT]) \
					if skill[skill_data.TARGET_LOW_ATTACK] else abs(skill[skill_data.ATTACK_WEIGHT])
				
				return hp_done + attack_done
			)
			
			var points_total = points.reduce(func(acc: float, num: float): return acc + num, .0)

			var random_number = randf_range(0, points_total)
			var percentage : float = 0
			
			for j in range(targets.size()):
				percentage += points[j]
				if  random_number <= percentage:
					result_target = data_to_choose_from[j]
					break 
		
		CombatantActionStorage.Type.HEAL:
			print("heal targeting in progress")
			print(targets,source)
	
	return result_target
