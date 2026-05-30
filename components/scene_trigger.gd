extends Area2D

@export_file("*.tscn") var target_scene: String

func _on_body_entered(_body: Node2D) -> void:
	assert(target_scene, "Target scene not set")
	SceneManager.change_scene_to(load(target_scene))
