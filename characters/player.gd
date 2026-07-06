extends CharacterBody2D

const SPEED := 180.0

@onready var animation_tree: AnimationTree = $AnimationTree

var last_input := Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Change facing direction ony if input is perpendicular or opposite
	# to last_input, like in undertale.
	if not input.is_zero_approx() and last_input.dot(input) <= 0.0:
		face_direction(input)

	velocity = input * SPEED
	move_and_slide()

func face_direction(dir: Vector2) -> void:
	last_input = dir
	animation_tree.set("parameters/Idling/blend_position", dir)
	animation_tree.set("parameters/Walking/blend_position", dir)
