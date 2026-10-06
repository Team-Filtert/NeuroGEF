class_name SequenceGoal
extends QuestNode

@export var children: Array[QuestNode] = []


func is_completed() -> bool:
	for child in children:
		if not child.is_completed():
			return false
	return true


func get_current_child() -> QuestNode:
	for child in children:
		if not child.is_completed():
			return child
	return null


func progress() -> float:
	if children.is_empty():
		return 0.0

	var children_done := 0
	for child in children:
		if child.is_completed():
			children_done += 1
	return float(children_done) / children.size()
