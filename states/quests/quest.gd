class_name Quest
extends Resource


@export var id: String
@export var name: String
@export var type: String
@export_multiline var description: String


@export var root: QuestNode


func is_completed() -> bool:
	return root != null and root.is_completed()


func progress() -> float:
	return root.progress() if root != null else 0.0
