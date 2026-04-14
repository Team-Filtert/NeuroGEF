@tool
class_name NpcBodyArea
extends Area2D

func _set_defaults() -> void:
	name = "NpcBodyArea"
	var body_collider = NpcBodyCollider.new()
	add_child(body_collider)
	body_collider.owner = get_tree().edited_scene_root
	body_collider._set_defaults()
