class_name NpcActionMove
extends NpcActionBase

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

@export var template: NpcStandardTemplate
@export var animation_player: NpcWalkingAnimationPlayer
@export var animated_sprite: NpcWalkingAnimatedSprite
@export var direction: DirectionOption = DirectionOption.UP
@export var distance: float = 50
@export var speed: float = 20

var animation_sufix: StringName
var vector: Vector2
var is_moving: bool = false
var target_pos: float
var start_pos: float
var remaining_dist: float

func _ready() -> void:
	wait = true
	
	match direction:
		DirectionOption.UP:
			animation_sufix = "up"
			vector = Vector2.UP
		DirectionOption.DOWN:
			animation_sufix = "down"
			vector = Vector2.DOWN
		DirectionOption.LEFT:
			animation_sufix = "left"
			vector = Vector2.LEFT
		DirectionOption.RIGHT:
			animation_sufix = "right"
			vector = Vector2.RIGHT

func _preform_action():
	is_moving = true
	remaining_dist = distance
	
	match direction:
		DirectionOption.UP:
			target_pos = template.position.y - distance
			start_pos = template.position.x
		DirectionOption.DOWN:
			target_pos = template.position.y + distance
			start_pos = template.position.x
		DirectionOption.LEFT:
			target_pos = template.position.x - distance
			start_pos = template.position.y
		DirectionOption.RIGHT:
			target_pos = template.position.x + distance
			start_pos = template.position.y
	
	if animation_player == null:
		animated_sprite.play("move_" + animation_sufix)
	else:
		animation_player.play("move_" + animation_sufix)

func _physics_process(delta: float) -> void:
	if is_moving:
		#anti stick to player below npc code
		match direction:
			DirectionOption.UP:
				remaining_dist = template.position.y - target_pos
				template.position.x = start_pos
			DirectionOption.DOWN:
				remaining_dist = target_pos - template.position.y
				template.position.x = start_pos
			DirectionOption.LEFT:
				remaining_dist = template.position.x - target_pos
				template.position.y = start_pos
			DirectionOption.RIGHT:
				remaining_dist = target_pos - template.position.x
				template.position.y = start_pos
		
		if speed * delta <= remaining_dist:
			#normal step
			template.velocity = vector * speed
			template.move_and_slide()
		else:
			#last step
			template.velocity = vector * remaining_dist / delta
			template.move_and_slide()
			if animation_player == null:
				animated_sprite.play("idle_" + animation_sufix)
			else:
				animation_player.play("idle_" + animation_sufix)
			done_action.emit()
			is_moving = false
