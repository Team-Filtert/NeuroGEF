extends Node

func _ready() -> void:
	SceneManager.scene_container = $SceneContainer
	UIManager.ui_layer = $UILayer
	UIManager.push_ui(preload("res://ui/main_menu.tscn"))
