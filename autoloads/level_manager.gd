extends Node

signal level_load_started
signal spawn_point_available(spawn_point: SpawnPoint)
signal level_load_finished

var _level_root: Node2D = null
var _transition_root: Control = null
var _current_level: Node2D = null
var _busy := false

func init(level_root: Node2D, transition_root: Control) -> void:
	_level_root = level_root
	_transition_root = transition_root

func change_level(level_path: String, spawn_id := "", transition_path := "") -> void:
	if _busy:
		return
		
	_busy = true
	level_load_started.emit()
	var transition: BaseTransition = null
	
	if not transition_path.is_empty():
		var transition_scene := load(transition_path) as PackedScene
		transition = transition_scene.instantiate()
		_transition_root.add_child(transition)
		@warning_ignore("redundant_await")
		await transition.play_in()
		
	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null
		await get_tree().process_frame
	
	var level := load(level_path) as PackedScene
	
	_current_level = level.instantiate()
	_level_root.add_child(_current_level)
	
	var spawn_point := _find_spawn_point(spawn_id)
	if not spawn_point:
		push_warning("SpawnPoint %s not found in %s" % [spawn_id, level_path])
	spawn_point_available.emit(spawn_point)
		
	if transition:
		@warning_ignore("redundant_await")
		await transition.play_out()
		transition.queue_free()
		transition = null
	
	_busy = false
	level_load_finished.emit()

func _find_spawn_point(spawn_id: String) -> SpawnPoint:
	for node in _current_level.get_tree().get_nodes_in_group("spawn_points"):
		if node.spawn_id == spawn_id:
			return node
	return null
