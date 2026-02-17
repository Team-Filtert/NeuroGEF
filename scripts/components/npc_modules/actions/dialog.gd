class_name NpcDialog
extends NpcActionBase

@export var timeline: DialogicTimeline

func _perform_action():
	Dialogic.start(timeline)
