extends Node

func _ready() -> void:
	PlayerManager.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, %TransitionRoot)
	
	PlayerManager.spawn_player()
	LevelManager.change_level("res://levels/ch1/neuros_home/neuros_room.tscn", "default")
