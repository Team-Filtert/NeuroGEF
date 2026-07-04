extends Node

func _ready() -> void:
	Game.initialize(%EntityRoot)
	LevelManager.initialize(%LevelRoot)
	
	Game.spawn_player()
	LevelManager.load_level("res://levels/starting/home/bedroom.tscn")
	
