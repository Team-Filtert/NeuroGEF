@tool
class_name NpcWalkingAnimationPlayer
extends AnimationPlayer

func _set_defaults() -> void:
	name = "NpcWalkingAnimationPlayer"
	var animations = preload("res://resources/animations/npc_walking_animations.tres")
	add_animation_library("", animations)
