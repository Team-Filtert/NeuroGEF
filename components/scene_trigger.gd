@tool
extends Area2D

@export_file("*.tscn") var target_scene: String

@export var trigger_size := Vector2(32, 32):
	set(value):
		trigger_size = value
		var shape_node := get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape:
			shape_node.shape.size = value
			

func _ready() -> void:
	trigger_size = trigger_size

func _on_body_entered(_body: Node) -> void:
	assert(target_scene, "Target scene not set")
	SceneManager.change_scene_to(load(target_scene))
