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
			action.target = ally
			
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
		
		
	





#this is a template and not all variables may exist in the real project

#static func pick_target():
	#someone will need to make skills with weights to them for targeting and pick a skill 
	
		# enemy weights let the enemy pick what target they would want more
		#var hp_weight = enemy.Get(health_weight)
		#var attack_weight = enemy.Get(attack_weight)
		
		#want it to be highest or lowest. just flips the % if its 100% makes it 0% thus someone with 100% hp left should not     
		#be targeted senses its flipped to 0% if its gets -1 if its 0 nothing changes.
		# if you make it 0 and keep the *- it will make it a multiplayer in the - 
		 
		#var hp_done = (ally.Get(health)/ally.Get(max_health)- 1or0) *- hp_weight
		#
		#var attack_done  = (ally.Get(attack) / global.Get(max_attack) - 1or0) *- attack_weight
		
		#if (hp_done + attack_done - global.Get(heat) > 0)
		  #points[i] = hp_done + attack_done
		#else
		  #points[i] = 1
