class_name NpcDialog
extends NpcActionBase

@export var timeline: DialogicTimeline

func _preform_action():
	Dialogic.start(timeline)
