@tool
class_name NpcWalkingAnimations
extends AnimationPlayer

func _set_defaults() -> void:
	name = "NpcWalkingAnimations"
	var animations = preload("res://resources/animations/npc_walking_animations.tres")
	add_animation_library("npc_walking_animations", animations)
	
