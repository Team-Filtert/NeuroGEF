# TODO: Method to get the facing direction as a vector
extends Marker2D

enum LookDirection { UP, LEFT, DOWN, RIGHT }

@export var spawn_id := "default"
@export var look_direction: LookDirection = LookDirection.DOWN