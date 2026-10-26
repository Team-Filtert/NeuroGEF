class_name AnyGoal
extends QuestNode

@export var children: Array[QuestNode] = []


func is_completed() -> bool:
	for child in children:
		if child.is_completed():
			return true
	return false


func progress() -> float:
	var highest := 0.0
	for child in children:
		highest = maxf(highest, child.progress())
	return highest
