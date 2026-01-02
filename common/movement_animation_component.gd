extends AnimatedSprite2D
class_name MovementAnimationComponent

@export var parent: Node2D
@export var input_component: InputComponent

var __move_vec = Vector2()

func _process(delta):
	if not input_component:
		return
	
	var move_vec = input_component.get_directional_input() as Vector2
	
	if move_vec.x > 0:
		trigger_anim("rightRun")
	elif move_vec.x < 0:
		trigger_anim("leftRun")
	elif move_vec.y > 0:
		trigger_anim("downRun")
	elif move_vec.y < 0:
		trigger_anim("upRun")

	if move_vec == Vector2.ZERO:
		if __move_vec.x > 0:
			trigger_anim("right")
		elif __move_vec.x < 0:
			trigger_anim("left")
		elif __move_vec.y > 0:
			trigger_anim("down")
		elif __move_vec.y < 0:
			trigger_anim("up")
	else:
		__move_vec = move_vec
	

func trigger_anim(animName: String):
	if animation != animName:
		play(animName)
