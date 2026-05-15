extends Node

#var scene_path_prefix: String = 'res://scenes/levels/'
var scene_path_postfix: String = '.tscn'
func str_to_scene_res_path(scene_name: String, scene_dir: String):
	if scene_dir.ends_with("/"):
		return scene_dir + scene_name + scene_path_postfix
	else:
		return scene_dir + "/" + scene_name + scene_path_postfix


@onready var transition_effect: Transition = $/root/Root/TransitionLayer/Transition

@onready var transition_time_out : bool = false

var current_scene: Node
var current_scene_name: String

@onready var scene_container_node: Node2D = $/root/Root/CurrentScene

var available_scene_transitions: Dictionary[String,SceneTransitionComponent]

func append_available_scene_transition(el: SceneTransitionComponent):
	available_scene_transitions[el.transition_id] = el

var starting_scene: String = "neuro_room"
var starting_scene_dir: String = "res://scenes/levels/ch1/neuro_house/"

func _ready():
	available_scene_transitions = {}
	current_scene_init()

func current_scene_init():
	if not scene_container_node.get_child_count() == 0:
		current_scene = scene_container_node.get_child(0)
		if current_scene:
			current_scene_name = current_scene.name

func change_scene_to(scene_name: String, scene_dir: String, cur_trans: SceneTransitionComponent):
	transition_time_out = true
	await transition_effect.transition_in()
	
	var new_scene_res = load(str_to_scene_res_path(scene_name,scene_dir))
	var target_trans_id = cur_trans.transition_to_id

	available_scene_transitions.clear()

	var new_scene = new_scene_res.instantiate()
	scene_container_node.call_deferred("add_child", new_scene)

	if current_scene:
		current_scene.call_deferred("free")
	
	call_deferred("current_scene_init")
	
	await get_tree().process_frame

	var target_trans: SceneTransitionComponent = available_scene_transitions[target_trans_id]
	
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
	
	PartyManager.overworld_party[0].position = target_pos
	
	
	await transition_effect.transition_out()
	transition_time_out = false
