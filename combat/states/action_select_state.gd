class_name ActionSelectState
extends ArenaStateBase

## Shows the current party member's available actions and waits for a choice.

var _actor: Combatant


func enter() -> void:
	_actor = arena.get_current_combatant()
	if _actor == null:
		arena.change_state(arena.queue_enemy_actions_state)
		return

	_actor.set_selected(true)
	arena.ui.show_message("%s's turn" % _actor.get_display_name())
	arena.ui.show_action_menu(arena.available_actions_for(_actor), _on_chosen, _on_flee)


func exit() -> void:
	if is_instance_valid(_actor):
		_actor.set_selected(false)
	arena.ui.clear_action_menu()


func _on_chosen(action: ActionBase) -> void:
	arena.pending_action = action
	arena.change_state(arena.target_select_state)


func _on_flee() -> void:
	arena.end_battle(false)
