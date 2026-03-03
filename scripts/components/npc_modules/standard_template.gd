@tool
class_name NpcStandardTemplate
extends CharacterBody2D

signal done_moving
signal done_animation

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

var sprite_sheet: Npc8x2SpriteSheet
var animation_player: NpcWalkingAnimationPlayer
var animated_sprite: NpcWalkingAnimatedSprite
var foot_collider: NpcFootCollider
var follower: NpcFollow

var is_moving: bool = false
var moving_distance: float
var moving_direction: DirectionOption
var moving_speed: float
var moving_vector: Vector2
var moving_target_pos: float
var moving_start_pos: float
var moving_animation_sufix: StringName

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		scale = Vector2(2, 2)
		
		sprite_sheet = Npc8x2SpriteSheet.new()
		animation_player = NpcWalkingAnimationPlayer.new()
		animated_sprite = NpcWalkingAnimatedSprite.new()
		foot_collider = NpcFootCollider.new()
		
		add_child(sprite_sheet)
		add_child(animation_player)
		add_child(animated_sprite)
		add_child(foot_collider)
		
		sprite_sheet.owner = get_tree().edited_scene_root
		animation_player.owner = get_tree().edited_scene_root
		animated_sprite.owner = get_tree().edited_scene_root
		foot_collider.owner = get_tree().edited_scene_root
		
		sprite_sheet._set_defaults()
		animation_player._set_defaults()
		animated_sprite._set_defaults()
		foot_collider._set_defaults()
	
	animation_player = get_children().filter(func(node): return node is NpcWalkingAnimationPlayer).front()
	animated_sprite = get_children().filter(func(node): return node is NpcWalkingAnimatedSprite).front()
	follower = get_children().filter(func(node): return node is NpcFollow).front()


func _physics_process(delta: float) -> void:
	if is_moving:
		#anti stick to player below npc code
		match moving_direction:
			DirectionOption.UP:
				moving_distance = position.y - moving_target_pos
				position.x = moving_start_pos
			DirectionOption.DOWN:
				moving_distance = moving_target_pos - position.y
				position.x = moving_start_pos
			DirectionOption.LEFT:
				moving_distance = position.x - moving_target_pos
				position.y = moving_start_pos
			DirectionOption.RIGHT:
				moving_distance = moving_target_pos - position.x
				position.y = moving_start_pos
		
		if moving_speed * delta <= moving_distance:
			#normal step
			velocity = moving_vector * moving_speed
			move_and_slide()
		else:
			#last step
			velocity = moving_vector * moving_distance / delta
			move_and_slide()
			play_animation("idle_" + moving_animation_sufix)
			done_moving.emit()
			is_moving = false

func move(direction: DirectionOption, distance: float, speed: float) -> void:
	moving_direction = direction
	moving_distance = distance
	moving_speed = speed
	is_moving = true

	
	match moving_direction:
		DirectionOption.UP:
			moving_target_pos = position.y - moving_distance
			moving_start_pos = position.x
			moving_animation_sufix = "up"
			moving_vector = Vector2.UP
		DirectionOption.DOWN:
			moving_target_pos = position.y + moving_distance
			moving_start_pos = position.x
			moving_animation_sufix = "down"
			moving_vector = Vector2.DOWN
		DirectionOption.LEFT:
			moving_target_pos = position.x - moving_distance
			moving_start_pos = position.y
			moving_animation_sufix = "left"
			moving_vector = Vector2.LEFT
		DirectionOption.RIGHT:
			moving_target_pos = position.x + moving_distance
			moving_start_pos = position.y
			moving_animation_sufix = "right"
			moving_vector = Vector2.RIGHT
	
	play_animation("move_" + moving_animation_sufix)

func turn(direction: DirectionOption) -> void:
	match direction:
		DirectionOption.UP:
			play_animation("idle_up")
		DirectionOption.DOWN:
			play_animation("idle_down")
		DirectionOption.LEFT:
			play_animation("idle_left")
		DirectionOption.RIGHT:
			play_animation("idle_right")

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

func start_following() -> void:
	if follower != null:
		follower.start_following()
	else:
		push_error("follow node is missing")

func stop_following() -> void:
	if follower != null:
		follower.stop_following()
	else:
		push_error("follow node is missing")
