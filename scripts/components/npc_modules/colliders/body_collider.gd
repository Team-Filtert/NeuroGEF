@tool
class_name NpcBodyCollider
extends CollisionShape2D

func _set_defaults() -> void:
	name = "NpcBodyCollider"
	shape = CircleShape2D.new()
	shape.radius = 46
