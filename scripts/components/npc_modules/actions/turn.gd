class_name NpcActionTurn
extends NpcActionBase

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

@export var animations: NpcWalkingAnimationPlayer
@export var direction: DirectionOption = DirectionOption.UP

var animation: StringName

func _ready() -> void:
	match direction:
		DirectionOption.UP:
			animation = "npc_walking_animations/idle_up"
		DirectionOption.DOWN:
			animation = "npc_walking_animations/idle_down"
		DirectionOption.LEFT:
			animation = "npc_walking_animations/idle_left"
		DirectionOption.RIGHT:
			animation = "npc_walking_animations/idle_right"

func _preform_action():
	animations.play(animation)
