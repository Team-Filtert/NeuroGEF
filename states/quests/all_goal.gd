class_name AllGoal
extends QuestNode

@export var children: Array[QuestNode] = []

func is_completed() -> bool:
	for child in children:
		if not child.is_completed():
			return false
	return true

func progress() -> float:
	var total = 0
	for child in children:
		total += child.progress()
	return total / children.size()