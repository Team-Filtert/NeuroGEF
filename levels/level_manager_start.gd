extends Node


func enter(args) -> void:
	PlayerManager.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, GameState._transition_root)
	PlayerManager.spawn_player()
	LevelManager.change_level("res://levels/ch1/neuros_home/neuro_room.tscn", "default")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
