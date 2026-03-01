class_name NpcActionStartFollowing
extends NpcActionBase

@export var follow_node: NpcFollow

func _preform_action():
	follow_node._start_following()
