extends Node

func _ready() -> void:
	SceneManager.scene_container = $SceneContainer
	UIManager.ui_layer = $UILayer
	UIManager.push_ui(preload("res://ui/main_menu.tscn"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		UIManager.push_ui(preload("res://ui/pause_menu.tscn"))
		get_tree().paused = true
		get_viewport().set_input_as_handled()
