class_name NpcActionAnimate
extends NpcActionBase

@export var animation_player: NpcWalkingAnimationPlayer
@export var animated_sprite: NpcWalkingAnimatedSprite
@export var animation_name: StringName

func _ready() -> void:
	wait = true

func _preform_action():
	if animation_player == null:
		animated_sprite.play(animation_name)
	else:
		animation_player.play(animation_name)
	done_action.emit()
