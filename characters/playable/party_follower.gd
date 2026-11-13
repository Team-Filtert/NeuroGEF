extends Node2D

## One overworld party member trailing the leader in a line.
##
## Followers don't run their own movement; they sample the leader's position
## history, so the party snakes along the leader's path. Spawned by
## [PlayerManager]; [member follow_distance] sets how far behind each one walks.
##
## Animation runs through the same [AnimationPlayer]/[AnimationTree] rig as the
## player, driven by the member's overworld sprite fields.

@export var follow_distance := 32.0

## Read by the AnimationTree transitions (same expression as the player).
var velocity := Vector2.ZERO

var leader: Node2D
var index := 1
var member: PartyMember

var _sprite: Sprite2D
var _animation_player: AnimationPlayer
var _animation_tree: AnimationTree
var _facing := Vector2.DOWN
var _idle_frame := 0


func setup(p_leader: Node2D, p_index: int, p_member: PartyMember) -> void:
	leader = p_leader
	index = p_index
	member = p_member

	_sprite = $Sprite2D as Sprite2D
	_animation_player = $AnimationPlayer as AnimationPlayer
	_animation_tree = $AnimationTree as AnimationTree

	OverworldAnimation.apply_sprite(member, _sprite)
	_idle_frame = clampi(member.get_overworld_frame(), 0, _sprite.hframes * _sprite.vframes - 1)

	var default_library := _animation_player.get_animation_library(OverworldAnimation.LIBRARY_NAME)
	OverworldAnimation.configure(_animation_player, _sprite, _idle_frame, default_library)
	_apply_blend_position()


func _physics_process(delta: float) -> void:
	if leader == null or not is_instance_valid(leader):
		return

	var target: Vector2 = leader.get_trail_position(index * follow_distance)
	var movement: Vector2 = target - global_position
	global_position = target

	if movement.length_squared() > 0.0001:
		_update_facing(movement)
		velocity = movement / delta
		_animation_player.speed_scale = clampf(velocity.length() / Player.SPEED, 0.5, 2.0)
		_apply_blend_position()
	else:
		velocity = Vector2.ZERO
		_animation_player.speed_scale = 1.0


## Stops sampling and returns the animation to its idle state.
func set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO
	if _animation_player != null:
		_animation_player.speed_scale = 1.0


func _update_facing(movement: Vector2) -> void:
	if absf(movement.x) > absf(movement.y):
		_facing = Vector2.RIGHT if movement.x > 0.0 else Vector2.LEFT
	elif movement.y != 0.0:
		_facing = Vector2.DOWN if movement.y > 0.0 else Vector2.UP


func _apply_blend_position() -> void:
	_animation_tree.set("parameters/Idling/blend_position", _facing)
	_animation_tree.set("parameters/Walking/blend_position", _facing)
