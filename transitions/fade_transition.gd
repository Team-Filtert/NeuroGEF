extends BaseTransition

@onready var color_rect: ColorRect = $ColorRect

func play_in() -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
func play_out() -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween.finished