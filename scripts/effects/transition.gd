extends TextureRect
class_name Transition

signal transition_over()

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func transition_in():
	anim_player.play("transition")
	await anim_player.animation_finished
	transition_over.emit()

func transition_out():
	anim_player.play_backwards("transition")
	await anim_player.animation_finished
	transition_over.emit()
