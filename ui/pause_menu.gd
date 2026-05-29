extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		UIManager.pop_ui()
		get_tree().paused = false
		get_viewport().set_input_as_handled()
		
func _on_resume_pressed() -> void:
	UIManager.pop_ui()
	get_tree().paused = false

func _on_save_pressed() -> void:
	SaveManager.save()
	print("Saved the game")
	
func _on_exit_pressed() -> void:
	get_tree().paused = false
	SceneManager.clear_scene()
	UIManager.clear_ui()
	UIManager.push_ui(preload("res://ui/main_menu.tscn"))
