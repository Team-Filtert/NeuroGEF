class_name AnyGoal
extends QuestNode

@export var children: Array[QuestNode] = []

func is_completed() -> bool:
	for child in children:
		if child.is_completed():
			return true
	return false

func progress() -> float:
	var total = 0
	for child in children:
		if child.progress() >= total:
			total = child.progress()
	return total
