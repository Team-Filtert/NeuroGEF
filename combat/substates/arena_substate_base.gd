class_name ArenaSubstateBase
extends Node

@export var next_substate: ArenaSubstateBase

@onready var parent: ArenaStateBase = get_parent()
@onready var arena: Arena = parent.arena

@warning_ignore("unused_parameter")
func enter(i: int) -> void:
	pass

func exit() -> void:
	pass
