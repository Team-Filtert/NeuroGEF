extends InputComponent
class_name ManualInput

func get_accept_input():
	if Input.is_action_just_pressed("ui_accept"):
		return true
	return false

func get_cancel_input():
	if Input.is_action_just_pressed("ui_cancel"):
		return true
	return false

func get_directional_input(one_time: bool = false):
	if one_time:
		return get_just_pressed_directional_input()

	var result = Vector2i()
	
	if Input.is_action_pressed("ui_right"):
		result.x += 1
	if Input.is_action_pressed("ui_left"):
		result.x -= 1
	if Input.is_action_pressed("ui_down"):
		result.y += 1
	if Input.is_action_pressed("ui_up"):
		result.y -= 1
	
	return result

func get_just_pressed_directional_input():
	var result = Vector2i()
	
	if Input.is_action_just_pressed("ui_right"):
		result.x += 1
	if Input.is_action_just_pressed("ui_left"):
		result.x -= 1
	if Input.is_action_just_pressed("ui_down"):
		result.y += 1
	if Input.is_action_just_pressed("ui_up"):
		result.y -= 1
	
	return result
