class_name EndTurnState extends ArenaStateBase

@export var startover_state: ArenaStateBase

func enter() -> void:
	parent.start_over()

func exit() -> void:
	pass