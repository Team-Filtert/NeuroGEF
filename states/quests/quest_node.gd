class_name QuestNode
extends Resource

func is_completed() -> bool:
	push_error("QuestNode.is_complete() was called directly")
	return false

func get_progress() -> float:
	return 0.0
