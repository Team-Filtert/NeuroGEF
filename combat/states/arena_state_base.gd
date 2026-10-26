class_name ArenaStateBase
extends Node

## Base class for arena states. States are direct children of the [Arena], so
## [member arena] is just the parent.

@onready var arena: Arena = get_parent()


func enter() -> void:
	pass


func exit() -> void:
	pass
