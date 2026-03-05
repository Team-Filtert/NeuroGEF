class_name CharacterBase
extends CharacterBody2D

signal done_moving
signal done_animation

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

var animation_player: AnimationPlayer
var animated_sprite: AnimatedSprite2D

var is_moving := false
var moving_direction: DirectionOption
var moving_speed: float
var moving_vector: Vector2
var moving_target_pos: float
var moving_start_pos: float
var moving_animation_sufix: StringName
var moving_remaining_dist: float

func connect_animation_nodes():
	animation_player = get_children().filter(func(node): return node is AnimationPlayer).front()
	animated_sprite = get_children().filter(func(node): return node is AnimatedSprite2D).front()

func script_control(delta: float):
	if is_moving:
		#anti stick to player below npc code
		match moving_direction:
			DirectionOption.UP:
				moving_remaining_dist = position.y - moving_target_pos
				position.x = moving_start_pos
			DirectionOption.DOWN:
				moving_remaining_dist = moving_target_pos - position.y
				position.x = moving_start_pos
			DirectionOption.LEFT:
				moving_remaining_dist = position.x - moving_target_pos
				position.y = moving_start_pos
			DirectionOption.RIGHT:
				moving_remaining_dist = moving_target_pos - position.x
				position.y = moving_start_pos
		
		if moving_speed * delta <= moving_remaining_dist:
			#normal step
			velocity = moving_vector * moving_speed
			move_and_slide()
		else:
			#last step
			velocity = moving_vector * moving_remaining_dist / delta
			move_and_slide()
			play_animation("idle_" + moving_animation_sufix)
			is_moving = false
			done_moving.emit()

func move(direction: DirectionOption, distance: float, script_speed: float) -> void:
	moving_direction = direction
	moving_speed = script_speed
	
	is_moving = true
	moving_remaining_dist = distance
	
	match moving_direction:
		DirectionOption.UP:
			moving_animation_sufix = "up"
			moving_vector = Vector2.UP
			moving_target_pos = position.y - distance
			moving_start_pos = position.x
		DirectionOption.DOWN:
			moving_animation_sufix = "down"
			moving_vector = Vector2.DOWN
			moving_target_pos = position.y + distance
			moving_start_pos = position.x
		DirectionOption.LEFT:
			moving_animation_sufix = "left"
			moving_vector = Vector2.LEFT
			moving_target_pos = position.x - distance
			moving_start_pos = position.y
		DirectionOption.RIGHT:
			moving_animation_sufix = "right"
			moving_vector = Vector2.RIGHT
			moving_target_pos = position.x + distance
			moving_start_pos = position.y
	
	play_animation("move_" + moving_animation_sufix)

func play_animation(animation_name: StringName, is_loop: bool = false) -> void:
	if animation_player == null:
		animated_sprite.play(animation_name)
		if not is_loop:
			await animated_sprite.animation_finished
			done_animation.emit()
	else:
		animation_player.play(animation_name)
		if not is_loop:
			await animation_player.animation_finished
			done_animation.emit()
