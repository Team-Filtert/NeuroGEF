extends Node

var _level_root: Node2D = null
var _current_level: Node2D = null

func initialize(level_root: Node2D) -> void:
	_level_root = level_root

# TODO: The spawning stuff
func load_level(path: String, spawn_id := "default") -> void:
	_do_load_level.call_deferred(path, spawn_id)

func _do_load_level(path: String, spawn_id := "default") -> void:
	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null

	var level := load(path) as PackedScene
	_current_level = level.instantiate()
	_level_root.add_child(_current_level)