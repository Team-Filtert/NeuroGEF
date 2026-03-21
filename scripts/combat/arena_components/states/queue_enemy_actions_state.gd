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
		
		var action = CombatantAction.new()
		action.type = CombatantAction.Type.ATTACK
		action.source = enemy
		
		var points : Array[float]
		var points_total : float = 0
		var percentag : float = 0
		var i : int = 0
		
		var temp_alive_party = alive_party
		temp_alive_party.shuffle()
		
		for ally in temp_alive_party:
			var hp_done = ally.health/ally.max_health
			var attack_done = ally.base_attack/99#change to max attack when made
			
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
