extends Node

# Old-level transitions now go through LevelManager (loading/instancing/
# transition-visual mechanics are shared with the new system) - this file
# keeps only what's specific to the old SceneTransitionComponent trigger
# scheme: computing a spawn position from a trigger's hit-box + direction,
# since old levels don't have SpawnPoint nodes for LevelManager to find.

var scene_path_postfix: String = '.tscn'
func str_to_scene_res_path(scene_name: String, scene_dir: String) -> String:
	if scene_dir.ends_with("/"):
		return scene_dir + scene_name + scene_path_postfix
	else:
		return scene_dir + "/" + scene_name + scene_path_postfix

var transition_time_out: bool = false

var available_scene_transitions: Dictionary[String, SceneTransitionComponent]

func append_available_scene_transition(el: SceneTransitionComponent):
	available_scene_transitions[el.transition_id] = el

var starting_scene: String = "neuro_room"
var starting_scene_dir: String = "res://levels/starting_area"

var _pending_target_trans_id: String = ""

func _ready():
	available_scene_transitions = {}

	# root.tscn (not main.tscn) is still the boot scene, so nothing else
	# calls LevelManager.init() - do it here instead of pre-placing a level
	# under a scene node, matching how CurrentScene worked before.
	var level_root := Node2D.new()
	add_child(level_root)

	var transition_layer := CanvasLayer.new()
	transition_layer.layer = 90
	add_child(transition_layer)
	var transition_root := Control.new()
	transition_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_layer.add_child(transition_root)

	LevelManager.init(level_root, transition_root)
	LevelManager.spawn_point_available.connect(_on_spawn_point_available)

func change_scene_to(scene_name: String, scene_dir: String, cur_trans: SceneTransitionComponent) -> void:
	transition_time_out = true
	available_scene_transitions.clear()
	_pending_target_trans_id = cur_trans.transition_to_id

	await LevelManager.change_level(str_to_scene_res_path(scene_name, scene_dir), "", "res://transitions/fade_transition.tscn")

	transition_time_out = false

func _on_spawn_point_available(spawn_point: SpawnPoint) -> void:
	if spawn_point or _pending_target_trans_id.is_empty():
		return

	var target_trans: SceneTransitionComponent = available_scene_transitions.get(_pending_target_trans_id)
	_pending_target_trans_id = ""
	if not target_trans:
		return

	var target_pos := (target_trans.get_parent() as Node2D).position
	var target_size: Vector2 = target_trans.get_parent().hit_box_size

	match target_trans.dir:
		0:
			target_pos.y -= 7 + (target_size.y / 2)
		1:
			target_pos.x += 12 + (target_size.x / 2)
		2:
			target_pos.y += 7 + (target_size.y / 2)
		3:
			target_pos.x -= 12 + (target_size.x / 2)

	if is_instance_valid(PlayerManager._player):
		PlayerManager._player.position = target_pos
