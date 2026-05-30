extends Node

var scene_container: Node

# TODO: Add some sort of validation to chech if the resource path is valid
func change_scene_to(scene: PackedScene) -> void:
	call_deferred("_do_change_scene", scene)
	
func _do_change_scene(scene: PackedScene) -> void:
	clear_scene()
	scene_container.add_child(scene.instantiate())

func clear_scene() -> void:
	for node in scene_container.get_children():
		node.queue_free()
