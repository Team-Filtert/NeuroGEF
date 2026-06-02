class_name ArenaStateBase
extends Node

@onready var parent: ArenaComponent = get_parent()
@onready var arena: Arena = parent.get_parent()

func enter():
	pass

func exit():
	pass
