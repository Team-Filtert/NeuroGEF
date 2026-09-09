class_name ArenaStateBase
extends Node

@export var next_state: ArenaStateBase

@onready var arena: Arena = get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass
