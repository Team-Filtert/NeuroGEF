class_name NpcActionTurn
extends NpcActionBase

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

@export var animation_player: NpcWalkingAnimationPlayer
@export var animated_sprite: NpcWalkingAnimatedSprite
@export var direction: DirectionOption = DirectionOption.UP

var animation: StringName

func _ready() -> void:
	match direction:
		DirectionOption.UP:
			animation = "idle_up"
		DirectionOption.DOWN:
			animation = "idle_down"
		DirectionOption.LEFT:
			animation = "idle_left"
		DirectionOption.RIGHT:
			animation = "idle_right"

func _preform_action():
	if animation_player == null:
		animated_sprite.play(animation)
	else:
		animation_player.play(animation)
