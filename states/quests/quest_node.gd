class_name QuestNode
extends Resource


func is_completed() -> bool:
	push_error("QuestNode.is_completed() was called directly; use a goal subclass.")
	return false


func progress() -> float:
	return 0.0
