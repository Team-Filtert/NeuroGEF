extends Node

func _ready() -> void:
	Game.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, %TransitionRoot)
	Game.spawn_player()
	LevelManager.change_level("res://levels/starting/home/bedroom.tscn", "default")
