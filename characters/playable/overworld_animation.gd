extends RefCounted

## Sprite and animation setup shared by the overworld leader and followers.

const LIBRARY_NAME := &"walk_cycle"


## Applies a party member's overworld sprite to [param sprite].
static func apply_sprite(member: PartyMember, sprite: Sprite2D) -> void:
	sprite.texture = member.get_overworld_texture()
	sprite.hframes = maxi(member.get_overworld_hframes(), 1)
	sprite.vframes = maxi(member.get_overworld_vframes(), 1)
	sprite.frame = member.get_overworld_frame()


## True for sheets laid out like `walk_cycle.tres` (three columns, four rows).
static func is_walk_cycle_sheet(sprite: Sprite2D) -> bool:
	return sprite.hframes == 3 and sprite.vframes == 4


## Ensures the AnimationPlayer has animations matching the current sprite sheet.
## The shared walk-cycle library is used when possible; other layouts get an
## equivalent library generated from their own frame count.
static func configure(
	animation_player: AnimationPlayer,
	sprite: Sprite2D,
	idle_frame: int,
	default_library: AnimationLibrary,
) -> void:
	var library := default_library if is_walk_cycle_sheet(sprite) else _make_generic_library(sprite, idle_frame)
	if library == null:
		return

	if animation_player.has_animation_library(LIBRARY_NAME):
		animation_player.remove_animation_library(LIBRARY_NAME)
	animation_player.add_animation_library(LIBRARY_NAME, library)


static func _make_generic_library(sprite: Sprite2D, idle_frame: int) -> AnimationLibrary:
	var walk_frames: Array[int] = []
	for i in sprite.hframes * sprite.vframes:
		walk_frames.append(i)

	var library := AnimationLibrary.new()
	for direction in ["down", "up", "left", "right"]:
		library.add_animation(StringName("idle_" + direction), _make_frame_animation([idle_frame], 0.001, false))
		library.add_animation(StringName("walk_" + direction), _make_frame_animation(walk_frames, 0.2, true))
	return library


static func _make_frame_animation(frames: Array, frame_time: float, loop: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(frames.size() * frame_time, 0.001)
	animation.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE

	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, ^"Sprite2D:frame")
	animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
	for i in frames.size():
		animation.track_insert_key(track, i * frame_time, frames[i])
	return animation
