class_name SpawnPoint
extends Marker2D

enum FacingDirection { UP, LEFT, DOWN, RIGHT }

@export var spawn_id: String
@export var facing_direction: FacingDirection = FacingDirection.DOWN

func get_facing_vector() -> Vector2:
	match facing_direction:
		FacingDirection.UP: return Vector2.UP
		FacingDirection.LEFT: return Vector2.LEFT
		FacingDirection.DOWN: return Vector2.DOWN
		FacingDirection.RIGHT: return Vector2.RIGHT
		_: return Vector2.DOWN
