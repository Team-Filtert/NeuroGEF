class_name NpcActionAnimate
extends NpcActionBase

@export var template: NpcTemplateBase
@export var animation_name: StringName
@export var is_loop: bool

func _ready() -> void:
	wait = true

func _preform_action():
	template.animate(animation_name, is_loop)
	await template.done_animation
	done_action.emit()
