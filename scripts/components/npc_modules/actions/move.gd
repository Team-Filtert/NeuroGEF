class_name NpcActionMove
extends NpcActionBase

const move_prefix: String = "move_"
const idle_prefix: String = "idle_"

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

func _ready() -> void:
	wait = true
	
	match direction:
		DirectionOption.UP:
			animation_sufix = "up"
			vector = Vector2.UP
			target_pos = template.position.y - distance
			start_pos = template.position.x
		DirectionOption.DOWN:
			animation_sufix = "down"
			vector = Vector2.DOWN
			target_pos = template.position.y + distance
			start_pos = template.position.x
		DirectionOption.LEFT:
			animation_sufix = "left"
			vector = Vector2.LEFT
			target_pos = template.position.x - distance
			start_pos = template.position.y
		DirectionOption.RIGHT:
			animation_sufix = "right"
			vector = Vector2.RIGHT
			target_pos = template.position.x + distance
			start_pos = template.position.y

func _preform_action():
	is_moving = true
	
	if animation_player == null:
		animated_sprite.play(move_prefix + animation_sufix)
	else:
		animation_player.play(move_prefix + animation_sufix)

func _physics_process(delta: float) -> void:
	if is_moving:
		#anti stick to player below npc code
		match direction:
			DirectionOption.UP:
				distance = template.position.y - target_pos
				template.position.x = start_pos
			DirectionOption.DOWN:
				distance = target_pos - template.position.y
				template.position.x = start_pos
			DirectionOption.LEFT:
				distance = template.position.x - target_pos
				template.position.y = start_pos
			DirectionOption.RIGHT:
				distance = target_pos - template.position.x
				template.position.y = start_pos
		
		if speed * delta <= distance:
			#normal step
			template.velocity = vector * speed
			template.move_and_slide()
		else:
			#last step
			template.velocity = vector * distance / delta
			template.move_and_slide()
			if animation_player == null:
				animated_sprite.play(idle_prefix + animation_sufix)
			else:
				animation_player.play(idle_prefix + animation_sufix)
			done_action.emit()
			is_moving = false
