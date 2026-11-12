class_name Player
extends CharacterBody2D

const OverworldAnimation := preload("res://characters/playable/overworld_animation.gd")

const SPEED := 180.0
const SPRINT := 1.7

## Number of recorded positions, newest first. Must cover the whole party's spacing.
const TRAIL_LENGTH := 300

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var _default_walk_library: AnimationLibrary
var _last_facing_direction := Vector2.DOWN
var _conflict_direction_mask := Vector2.DOWN

## Recent positions, newest first; party followers read from this to trail behind.
var _trail: Array[Vector2] = []


func set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO


func _ready() -> void:
	_default_walk_library = animation_player.get_animation_library(OverworldAnimation.LIBRARY_NAME)


## Applies the party leader's overworld sprite and animation setup.
func apply_member_sprite(member: PartyMember) -> void:
	OverworldAnimation.apply_sprite(member, sprite)
	OverworldAnimation.configure(animation_player, sprite, member.get_overworld_frame(), _default_walk_library)
	set_facing(_last_facing_direction)


## Returns the point [param distance_px] pixels behind the leader along the trail.
func get_trail_position(distance_px: float) -> Vector2:
	if distance_px <= 0.0 or _trail.is_empty():
		return global_position

	var remaining := distance_px
	var from := global_position
	for to in _trail:
		var segment := from.distance_to(to)
		if segment >= remaining:
			return from.lerp(to, remaining / segment) if segment > 0.0 else to
		remaining -= segment
		from = to
	return from


## Forgets the trail, e.g. after being teleported to a new level.
func reset_trail() -> void:
	_trail.clear()


func _record_trail() -> void:
	if _trail.is_empty() or global_position.distance_to(_trail[0]) >= 1.0:
		_trail.push_front(global_position)
		if _trail.size() > TRAIL_LENGTH:
			_trail.resize(TRAIL_LENGTH)


func set_facing(dir: Vector2) -> void:
	_last_facing_direction = dir
	animation_tree.set("parameters/Idling/blend_position", dir)
	animation_tree.set("parameters/Walking/blend_position", dir)


func _physics_process(_delta: float) -> void:
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)

	# Four-way movement: when two directions are held, keep the axis of the key
	# that was added last. Only update the mask on cardinal input, otherwise
	# releasing all keys would zero it and block the next diagonal press.
	if input.x != 0.0 and input.y != 0.0:
		input *= _conflict_direction_mask
	elif not input.is_zero_approx():
		_conflict_direction_mask = abs(Vector2(input.y, input.x))

	var sprinting := Input.is_action_pressed("sprint")
	var facing := input.normalized() if not input.is_zero_approx() else Vector2.ZERO
	if facing != Vector2.ZERO and facing != _last_facing_direction:
		set_facing(facing)

	velocity = input * SPEED * (SPRINT if sprinting else 1.0)
	animation_player.speed_scale = SPRINT if sprinting else 1.0
	move_and_slide()
	_record_trail()
