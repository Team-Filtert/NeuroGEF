extends Control

func enter(args) -> void:
	pass # Replace with function body.

func _ready() -> void:
	$Buttons/LoadGame.grab_focus()

func _on_load_game_pressed() -> void:
	#temp code
	GameState.push("res://levels/level_manager.tscn")

func _on_new_game_pressed() -> void:
	#temp code
	GameState.push("res://levels/level_manager.tscn")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
