extends Control

func _on_play_pressed() -> void:
	UIManager.push_ui(preload("res://ui/save_selection_menu.tscn"))

func _on_options_pressed() -> void:
	UIManager.push_ui(preload("res://ui/options_menu.tscn"))

func _on_quit_pressed() -> void:
	get_tree().quit()
