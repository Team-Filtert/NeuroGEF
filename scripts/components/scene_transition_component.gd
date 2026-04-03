extends Node
class_name SceneTransitionComponent


@export var transition_id = -1
@export var transition_to_id = -1
@export var to_scene_name: String
@export var collision_area: Area2D

func _ready():
	collision_area.body_entered.connect(enter_scene)

	GameManager.scene_manager.append_available_scene_transition(self)

func enter_scene(body: Node2D):
	if body.is_in_group("player"):
		GameManager.scene_manager.change_scene_to(to_scene_name, self)
