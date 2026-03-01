class_name NpcActionStopFollowing
extends NpcActionBase

@export var follow_node: NpcFollow

func _preform_action():
	follow_node._stop_following()
