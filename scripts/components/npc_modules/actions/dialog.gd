class_name NpcActionDialog
extends NpcActionBase

@export var timeline: DialogicTimeline

func _preform_action():
	CutsceneManager.start_cutscene(timeline)
