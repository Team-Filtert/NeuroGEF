class_name NpcTurn
extends NpcActionBase

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

@export var direction: DirectionOption = DirectionOption.UP

var animation: StringName
var player: NpcWalkingAnimations

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
	
	player = $"../../NpcWalkingAnimations"

func _preform_action():
	player.play(animation)
