class_name EndTurnState
extends ArenaStateBase

## Wraps up a full round: clears per-turn status and starts the next cycle.

func enter() -> void:
	arena.start_over()
	if arena.has_battle_ended():
		return
	arena.change_state(arena.action_select_state)
