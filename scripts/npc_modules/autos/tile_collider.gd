@tool
class_name NpcTileCollider
extends CollisionShape2D

func _set_defaults() -> void:
	name = "NpcTileCollider"
	shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
