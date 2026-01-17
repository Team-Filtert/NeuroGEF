extends Camera2D

@export var object_to_follow: Node2D

var follow_tween: Tween

@export var x_up_constraint: int = 0
@export var x_down_constraint: int = 0
@export var y_up_constraint: int = 0
@export var y_down_constraint: int = 0

@export var follow_duration: float = 2.0

func create_follow_tween():
	follow_tween = create_tween()
	follow_tween.set_trans(Tween.TRANS_LINEAR)

	follow_tween.tween_interval(0)

	follow_tween.tween_method(_lerp_to_target, 0.0, 1.0, follow_duration)

func _lerp_to_target(progression:float):
	var target_position = object_to_follow.global_position

	global_position = lerp(global_position, target_position, progression)

	global_position.x = clamp(global_position.x, x_down_constraint, x_up_constraint)
	global_position.y = clamp(global_position.y, y_down_constraint, y_up_constraint)

func _process(_delta):
	if not follow_tween or not follow_tween.is_valid():
		create_follow_tween()
	
