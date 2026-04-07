extends Node

var scene_path_prefix: String = 'res://scenes/levels/'
var scene_path_postfix: String = '.tscn'
func str_to_scene_res_path(scene_name: String):
	return scene_path_prefix + scene_name + scene_path_postfix

@onready var transition_effect: Transition = $/root/Root/TransitionLayer/Transition


var current_scene: Node
var current_scene_name: String

@onready var scene_container_node: Node2D = $/root/Root/CurrentScene

var available_scene_transitions: Array[SceneTransitionComponent]

func get_scene_transition_by_id(id: int) -> SceneTransitionComponent:
	var st_arr_filtered = available_scene_transitions.filter(
		func (el: SceneTransitionComponent):
			return el.transition_id == id
	)

	return st_arr_filtered[0]

func append_available_scene_transition(el: SceneTransitionComponent):
	available_scene_transitions.append(el)

var starting_scene: String = "home"

func _ready():
	available_scene_transitions = []
	current_scene_init()

func current_scene_init():
	if not scene_container_node.get_child_count() == 0:
		current_scene = scene_container_node.get_child(0)
		if current_scene:
			current_scene_name = current_scene.name

func change_scene_to(scene_name: String, cur_trans: SceneTransitionComponent, player: CharacterBase):
	player.is_input_control = false
	await transition_effect.transition_in()
	
	var new_scene_res = load(str_to_scene_res_path(scene_name))
	var target_trans_id = cur_trans.transition_to_id

	available_scene_transitions.clear()

	var new_scene = new_scene_res.instantiate()
	scene_container_node.call_deferred("add_child", new_scene)

	if current_scene:
		current_scene.call_deferred("free")
	
	call_deferred("current_scene_init")
	
	await get_tree().process_frame

	var target_trans: SceneTransitionComponent = get_scene_transition_by_id(target_trans_id)

	PartyManager.overworld_party[0].position = (target_trans.get_parent() as Node2D).position
	
	await transition_effect.transition_out()
	player.is_input_control = true
