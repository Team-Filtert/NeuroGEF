extends Node
class_name SceneTransitionComponent


@export var transition_id : String
@export var transition_to_id : String
@export var to_scene_name: String
@export var collision_area: Area2D
@export var scene_directory: String
var dir : int


func _ready():
	collision_area.body_entered.connect(enter_scene)
	dir = self.get_parent().dir
	#print(dir)
	#print(transition_id)
	#print(transition_to_id)
	#print(to_scene_name)
	SceneManager.append_available_scene_transition(self)

func enter_scene(body: Node2D):
	if body.is_in_group("player"):

		SceneManager.change_scene_to(to_scene_name,scene_directory, self)
