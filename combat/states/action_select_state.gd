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
	arena.ui.show_action_menu(arena.available_actions_for(_actor), _on_chosen, _on_flee, _on_inspect)


func exit() -> void:
	if is_instance_valid(_actor):
		_actor.set_selected(false)
	arena.ui.clear_action_menu()


func _on_chosen(action: ActionBase) -> void:
	arena.pending_action = action
	arena.change_state(arena.target_select_state)


func _on_flee() -> void:
	arena.end_battle(false)


func _on_inspect() -> void:
	arena.ui.set_action_menu_enabled(false)
	arena.target_indicator.highlight_changed.connect(_show_inspect_stats)
	var target: Combatant = await arena.target_indicator.choose(arena.get_alive_enemies())
	arena.target_indicator.highlight_changed.disconnect(_show_inspect_stats)
	arena.ui.set_action_menu_enabled(true)
	if target == null:
		return
	# Let the menu restore its focus first, otherwise its description overwrites this.
	await get_tree().process_frame
	arena.ui.show_combatant_info(target)


func _show_inspect_stats(combatant: Combatant) -> void:
	arena.ui.show_combatant_info(combatant)
