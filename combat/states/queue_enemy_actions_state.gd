class_name QueueEnemyActionsState
extends ArenaStateBase

## Lets the AI queue one action per living enemy, then moves on to resolution.

func enter() -> void:
	for enemy in arena.get_alive_enemies():
		var action := arena.ai.choose_action(enemy, arena)
		if action != null:
			arena.submit_action(action)

	arena.change_state(arena.action_resolve_state)
