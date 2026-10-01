extends Node

func _ready() -> void:
	GameState.init(%StateManager, %TransitionRoot)
	GameState.push("res://ui/ui_scenes/starting_screen.tscn")
	# PlayerManager.init(%PlayerRoot)
	# LevelManager.init(%LevelRoot, %TransitionRoot)
	# print("Main Initlized:", %PlayerRoot, %LevelRoot, %TransitionRoot)
	# LevelManager.init(%LevelRoot, %TransitionRoot)
	
	# PlayerManager.spawn_player()
	# LevelManager.change_level("res://levels/ch1/neuros_home/neuro_room.tscn", "default")
