class_name TargetSelectState
extends ArenaStateBase

## Picks the target for the pending action (or skips straight through for
## self/AoE actions), then submits it and advances the turn.


func enter() -> void:
	_select()


func _select() -> void:
	var action := arena.pending_action
	arena.pending_action = null
	var actor := arena.get_current_combatant()

	if action == null or actor == null:
		arena.change_state(arena.action_select_state)
		return

	action.source = actor

	# Self-targeted and AoE actions don't need a picker.
	if action.hits_all or action.target_side == ActionBase.TargetSide.SELF:
		action.target = actor if action.target_side == ActionBase.TargetSide.SELF else null
		_submit(action)
		return

	var candidates := arena.targets_for(action, actor)
	if candidates.is_empty():
		arena.change_state(arena.action_select_state)
		return

	var target: Combatant = await arena.target_indicator.choose(candidates)
	if target == null:
		arena.change_state(arena.action_select_state)
		return

	action.target = target
	_submit(action)


func _submit(action: ActionBase) -> void:
	arena.submit_action_player(action)
	if arena.check_player_turn_over():
		arena.change_state(arena.queue_enemy_actions_state)
	else:
		arena.change_state(arena.action_select_state)
