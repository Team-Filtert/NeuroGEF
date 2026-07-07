extends Node

signal level_load_started
signal spawn_point_ready(spawn_point: SpawnPoint)
signal level_load_finished

var _current_level: Node2D = null
var _current_transition: BaseTransition = null
var _level_root: Node2D = null
var _transition_root: Control = null

func init(level_root: Node2D, transition_root: Control) -> void:
	_level_root = level_root
	_transition_root = transition_root

func load_level(level_path: String, spawn_id := "", transition_path := "") -> void:
	var use_transition := not transition_path.is_empty()

	level_load_started.emit()

	if use_transition:
		var transition_scene := load(transition_path) as PackedScene
		_current_transition = transition_scene.instantiate()
		_transition_root.add_child(_current_transition)
		@warning_ignore("redundant_await")
		await _current_transition.play_in()

	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null
		await get_tree().process_frame

	var level_scene := load(level_path) as PackedScene
	
	_current_level = level_scene.instantiate()
	_level_root.add_child(_current_level)

	var spawn_point := _find_spawn_point(spawn_id)
	if not spawn_point:
		push_warning("SpawnPoint '%s' not found in '%s'" % [spawn_id, level_path])
	spawn_point_ready.emit(spawn_point)

	if use_transition:
		@warning_ignore("redundant_await")
		await _current_transition.play_out()
		_current_transition.queue_free()
		_current_transition = null

	level_load_finished.emit()

func _find_spawn_point(spawn_id: String) -> SpawnPoint:
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node.spawn_id == spawn_id:
			return node
	return null