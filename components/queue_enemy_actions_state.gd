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


func data_to_calculated_points(input_data: Array[Combatant], points_calculator: Callable) -> Array:
	return input_data.map(points_calculator)

func pick_action(source: Combatant) -> CombatantAction:
	var alive_enemies := parent.get_alive_enemies()
	var alive_party := parent.get_alive_party()

	var action: CombatantAction
	
	# All skills of current enemy that we choose of
	var enemy_actions := source.attack_actions

	var vulnerability_criteria = func(cur_target: Combatant):
		return cur_target.get_health() + cur_target.get_defense() - source.get_attack() <= 0
	
	var heal_criteria = func(cur_target: Combatant):
		return cur_target.get_health() - source.base_magic <= 0
	
	# picking skill to use
	for i in range(enemy_actions.size()):
		
		if enemy_actions[i] is BasicAttackAction:
			var points: Array = data_to_calculated_points(alive_party, func(pm: Combatant):
				if (vulnerability_criteria.call(pm)):
					return 25
				else:
					return 5
			)
	
			var highest = points.max()
			var temp_int = points.find(highest)
				
			action = enemy_actions[temp_int]
			action.target = pick_target(
				action,
				alive_party,
				source
			)
		elif enemy_actions[i] is BasicHealAction:
			var points: Array = data_to_calculated_points(alive_enemies, func(enemy: Combatant):
				if (heal_criteria.call(enemy)):
					return 10
				else:
					return 3
				)
	
			var highest = points.max()
			var temp_int = points.find(highest)
			
			action = enemy_actions[temp_int]
			action.target = pick_target(
				action,
				alive_enemies,
				source
			)
		
	
	return action


func pick_target(action: CombatantAction, targets: Array, source) -> Combatant:
	var result_target: Combatant
	
	var weights := action.ai_weights
	var data_to_choose_from = targets
	data_to_choose_from.shuffle()
	
	if action.type == CombatantAction.Type.NONE:
		print("CombatantAction's type is NONE")
	elif action.type == CombatantAction.Type.ATTACK:
		var points = data_to_calculated_points(data_to_choose_from, func(target: Combatant):
			var hp_done = float(target.get_health()) / target.get_max_health() * weights.hp_weight \
					if weights.target_low_hp else .0
				
			#change to max attack instead of 99
			var attack_done = float(target.get_attack()) / 99  * weights.attack_weight \
					if weights.target_low_attack else .0
				
			return hp_done + attack_done
		)
			
		var points_total = points.reduce(func(acc: float, num: float): return acc + num, .0)

		var random_number = randf_range(0, points_total)
		var percentage : float = 0
			
		for i in range(targets.size()):
			percentage += points[i]
			if  random_number <= percentage:
				result_target = data_to_choose_from[i]
				break 
		
	elif action.type == CombatantAction.Type.HEAL:
		print("heal targeting in progress")
		print(targets,source)
	
	return result_target
