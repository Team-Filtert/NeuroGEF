extends Node

func _ready() -> void:
	PlayerManager.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, %TransitionRoot)
	
	PlayerManager.spawn_player()
	LevelManager.change_level("res://levels/starting/home/bedroom.tscn", "default")
