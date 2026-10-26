class_name Player
extends CharacterBody2D

const SPEED := 180.0
const SPRINT := 1.7

@onready var animation_tree: AnimationTree = $AnimationTree

var _last_facing_direction := Vector2.DOWN
var _conflict_direction_mask := Vector2.DOWN
var _is_paused := false

## Recent positions, newest first; party followers read from this to trail behind.
const TRAIL_LENGTH := 120
var _trail: Array[Vector2] = []


func set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO


## Returns the position the leader was at [param index] physics frames ago.
func get_trail_position(index: int) -> Vector2:
	if _trail.is_empty():
		return global_position
	return _trail[clampi(index, 0, _trail.size() - 1)]


## Forgets the trail, e.g. after being teleported to a new level.
func reset_trail() -> void:
	_trail.clear()


func _record_trail() -> void:
	_trail.push_front(global_position)
	if _trail.size() > TRAIL_LENGTH:
		_trail.resize(TRAIL_LENGTH)

func set_facing(dir: Vector2) -> void:
	_last_facing_direction = dir
	animation_tree.set("parameters/Idling/blend_position", dir)
	animation_tree.set("parameters/Walking/blend_position", dir)

func _physics_process(_delta: float) -> void:

	var input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

	input *= SPRINT if Input.is_action_pressed("sprint") else 1

	if input.x != 0 and input.y != 0:
		input *= _conflict_direction_mask
		#input *= (1/sqrt(2))+0.05
	else:
		_conflict_direction_mask = abs(Vector2(input.y, input.x))


	if not input.is_zero_approx() and _last_facing_direction != input:
		set_facing(input)

	velocity = input * SPEED
	move_and_slide()
	_record_trail()
