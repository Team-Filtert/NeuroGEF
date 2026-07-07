extends Node

func _ready() -> void:
	Global.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, %TransitionRoot)
	Global.spawn_player()
	LevelManager.change_level("res://levels/starting/home/bedroom.tscn", "default")
