class_name TargetSelectState extends ArenaStateBase

@export var action_selection_state: ArenaStateBase
@export var enemy_turn_state: ArenaStateBase

var action: CombatantAction

func enter():
	action = parent.pending_action
	parent.pending_action = null
	_select_target()

func _select_target() -> void:
	var alive_enemies = parent.get_alive_enemies()
	var target = await parent.wait_for_target_selection(alive_enemies)
	
	if target:
		action.target = target
		parent.submit_action_player(action)
		
		if parent.check_player_turn_over():
			parent.change_state(enemy_turn_state)
		else:
			parent.reset_menu()
	else:
		parent.change_state(action_selection_state)
