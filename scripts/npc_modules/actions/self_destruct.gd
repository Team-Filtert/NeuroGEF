class_name NpcActionSelfDestruct
extends NpcActionBase

@export var template: NpcTemplateBase

func _preform_action() -> void:
	template.queue_free()
