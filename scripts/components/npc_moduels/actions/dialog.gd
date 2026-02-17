class_name NpcDialog
extends NpcActionTemplate

@export var timeline: DialogicTimeline

func _perform_action():
	Dialogic.start(timeline)
