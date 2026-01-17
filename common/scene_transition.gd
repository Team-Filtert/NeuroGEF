extends Node2D

@export var scene_to_transition: String
@export var position_to_place_player: Vector2

func transition_to_scene() -> void:
	var scene_manager: SceneManager = GlobalManager.get_scene_manager()
	scene_manager.load_level(scene_to_transition, position_to_place_player)

func on_trigger_area_body_entered(body):
	if body is PlayerCharacter:
		transition_to_scene()
