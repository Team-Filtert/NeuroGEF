class_name Player
extends CharacterBody2D

const SPEED := 180.0

@onready var animation_tree: AnimationTree = $AnimationTree

var _last_facing_direction := Vector2.DOWN
var _conflict_direction_mask := Vector2.DOWN

func set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO

func set_facing(dir: Vector2) -> void:
	_last_facing_direction = dir
	animation_tree.set("parameters/Idling/blend_position", dir)
	animation_tree.set("parameters/Walking/blend_position", dir)

func _physics_process(_delta: float) -> void:
	var input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

	if input.x != 0 and input.y != 0:
		input *= _conflict_direction_mask
	else:
		_conflict_direction_mask = abs(Vector2(input.y, input.x))
		
	if not input.is_zero_approx() and _last_facing_direction != input:
		set_facing(input)

	velocity = input * SPEED
	move_and_slide()
