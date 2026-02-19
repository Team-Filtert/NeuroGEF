class_name NpcDelay
extends NpcActionBase

@export var seconds: float = 1

func _ready() -> void:
	wait = true

func _preform_action():
	await get_tree().create_timer(seconds).timeout
	done_action.emit()
