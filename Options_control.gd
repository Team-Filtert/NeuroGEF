extends Control




func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
