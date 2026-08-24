class_name PersistenceGoal 
extends QuestNode


@export var key: String
@export var expected_value: Variant = true

func is_completed() -> bool:
	if GameState.keys.has(key):
		return GameState.keys.value(key) == expected_value
	return false

func progress() -> float:
	return 1.0 if is_completed() else 0.0