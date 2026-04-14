class_name NpcModeBase
extends Node

@export var is_active := false

func start():
	if is_active:
		_activate()

func _activate() -> void:
	pass

func _deactivate() -> void:
	pass
