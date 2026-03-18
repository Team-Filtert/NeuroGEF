class_name EndTurnState extends ArenaStateBase

@export var startover_state: ArenaStateBase

func enter() -> void:
	parent.action_queue.clear()
	parent.player_actions_submitted = 0
	parent.awaiting_player_input = true
	
	for c in parent.get_all_alive_combatants():
		c.reset_status()
	
	parent.get_current_combatant().set_selected(true)
	parent.change_state(startover_state)

func exit() -> void:
	pass