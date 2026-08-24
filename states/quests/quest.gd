class_name Quest
extends Resource


@export var id: String
@export var name: String
@export var type: String
@export_multiline var description: String


@export var root: QuestNode

func is_complete() -> bool:
    return root.is_complete()

func progress() -> float:
    return root.progress()