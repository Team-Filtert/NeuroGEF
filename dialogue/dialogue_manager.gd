extends Control
class_name DialogueManager

@export var ui_manager: DialogueUIManager

signal dialogue_finished

func start_dialogue(scene: DialogueScene) -> void:
	get_tree().paused = true
	ui_manager.visible = true
	ui_manager.init(scene)

func finish_dialogue() -> void:
	get_tree().paused = false
	ui_manager.visible = false
	dialogue_finished.emit()
