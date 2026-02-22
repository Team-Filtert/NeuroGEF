class_name NpcActionMove
extends NpcActionBase

const move_prefix: String = "npc_walking_animations/move_"
const idle_prefix: String = "npc_walking_animations/idle_"

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

@export var template: NpcStandardTemplate
@export var animations: NpcWalkingAnimations
@export var direction: DirectionOption = DirectionOption.UP
@export var distance: float = 50
@export var speed: float = 20

var animation_sufix: StringName
var player: NpcWalkingAnimations
var vector: Vector2
var is_walking: bool = false

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
	animations.play(move_prefix + animation_sufix)
	is_walking = true

func _physics_process(delta: float) -> void:
	if is_walking:
		if speed * delta < distance:
			#normal step
			distance = distance - speed * delta
			template.velocity = vector * speed
			template.move_and_slide()
		else:
			#last step
			template.velocity = vector * distance
			template.move_and_slide()
			animations.play(idle_prefix + animation_sufix)
			done_action.emit()
			is_walking = false
