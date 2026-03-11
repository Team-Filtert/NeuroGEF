class_name NpcActionToggleMode
extends NpcActionBase

@export var template: NpcTemplateStandard
@export var mode_name: StringName

func _preform_action():
	template.toggle_mode(mode_name)
