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
		action.target = alive_party.pick_random()
		parent.action_queue.append(action)