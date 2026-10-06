class_name ActionResolveState
extends ArenaStateBase

## Runs the queued actions in speed order (fastest first). Each action is
## animated, its timing challenge resolved, and its effect applied; the battle is
## re-checked after every action so a mid-turn KO ends things cleanly.

func enter() -> void:
	_resolve()


func _resolve() -> void:
	arena.action_queue.sort_custom(_faster_first)

	for action in arena.action_queue:
		if action.source == null or not action.source.is_alive():
			continue

		await arena.perform_action(action)
		arena.refresh_ui()

		if arena.has_battle_ended():
			return

	arena.change_state(arena.end_turn_state)


func _faster_first(a: ActionBase, b: ActionBase) -> bool:
	return a.source.get_speed() > b.source.get_speed()
