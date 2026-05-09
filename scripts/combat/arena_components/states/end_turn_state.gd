class_name EndTurnState
extends ArenaStateBase

func enter() -> void:
	parent.start_over()

func exit() -> void:
	pass
