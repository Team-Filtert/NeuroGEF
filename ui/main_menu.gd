extends Control

@onready var quit_button_texture: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/QuitButton/TextureRect

func _ready() -> void:
	#placeholder theme
	AudioManager.play_bgm(preload("res://assets/bgm/themenew_v2_mastered_loop.ogg"))

func _on_play_pressed() -> void:
	UIManager.push_ui(preload("res://ui/save_selection_menu.tscn"))

func _on_options_pressed() -> void:
	UIManager.push_ui(preload("res://ui/options_menu.tscn"))

func _on_quit_pressed() -> void:
	get_tree().quit()
