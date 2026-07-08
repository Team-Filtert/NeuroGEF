@tool
extends Area2D

@export var spawn_id: String
@export_file("*.tscn") var target_scene: String:
	set(value):
		target_scene = value
		update_configuration_warnings()    
@export_file("*.tscn") var transition_scene: String

func _on_body_entered(_body: Node2D) -> void:
	LevelManager.change_level(target_scene, spawn_id, transition_scene)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if target_scene.is_empty():
		warnings.append("Target scene is not set.")
	return warnings