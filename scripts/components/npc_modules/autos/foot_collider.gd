@tool
class_name NpcFootCollider
extends CollisionShape2D

func _set_defaults() -> void:
	name = "NpcFootCollider"
	shape = RectangleShape2D.new()
	shape.size = Vector2(10, 5)
	position = Vector2(0, 11.5)
