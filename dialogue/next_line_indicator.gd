extends TextureRect
class_name NextLineIndicator


var is_next_line_ready: bool:
	set(value):
		visible = value
		animation_player.play("Show" if value else "Hide")
	get:
		return visible

@export var animation_player: AnimationPlayer
