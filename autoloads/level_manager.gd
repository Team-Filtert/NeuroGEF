extends Node

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
	
	var transition: BaseTransition = null
	# NOTE: Maybe we should allow for explicit control over set_player_active
	PlayerManager.set_player_active(false)
	
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
	
	var level_scene := load(level_path) as PackedScene
	_current_level = level_scene.instantiate()
	_level_root.add_child(_current_level)
	
	var spawn_point := _find_spawn_point(spawn_id)
	if spawn_point:
		PlayerManager.set_player_position(spawn_point.global_position)
		PlayerManager.set_player_facing(spawn_point.get_facing_vector())
	else:
		push_warning("LevelManager: SpawnPoint '%s' not found in %s" % [spawn_id, level_path])
	
	if transition:
		@warning_ignore("redundant_await")
		await transition.play_out()
		transition.queue_free()
	
	PlayerManager.set_player_active(true)
	_busy = false
	
func _find_spawn_point(spawn_id: String) -> SpawnPoint:
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node is SpawnPoint and node.spawn_id == spawn_id:
			return node
	return null