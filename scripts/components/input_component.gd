class_name InputComponent
extends Node

var hold_timer: float = 0.0

func get_held_vector_input() -> Vector2:
	var input := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input += Vector2.UP
	if Input.is_action_pressed("move_down"):
		input += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		input += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		input += Vector2.RIGHT
	return input

func get_just_pressed_vector_input() -> Vector2:
	var input := Vector2.ZERO
	if Input.is_action_just_pressed("move_up"):
		input += Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		input += Vector2.DOWN
	if Input.is_action_just_pressed("move_left"):
		input += Vector2.LEFT
	if Input.is_action_just_pressed("move_right"):
		input += Vector2.RIGHT
	return input

## Returns a Vector2 representing the directional input based on the defined actions.
## If `action_held` is true, it checks for actions being held down; otherwise, 
## it checks for just pressed actions.
## If `hold_after_time` is set to non-zero, input checks for just_pressed
## until the hold timer exceeds the specified time, after which it checks for held actions.
func get_vector_input_base(action_held: bool, hold_after_time: float) -> Vector2:
	var input := Vector2.ZERO

	var hold_after_long_press := hold_after_time != 0.0 && (hold_timer > hold_after_time)

	var held_vector_input := get_held_vector_input()
	var just_pressed_vector_input := get_just_pressed_vector_input()
	
	if action_held or hold_after_long_press:
		input += held_vector_input

		if held_vector_input == Vector2.ZERO:
			hold_timer = 0.0
	else:
		input += just_pressed_vector_input
		
		if hold_after_time != 0.0 and held_vector_input != Vector2.ZERO:
			hold_timer += get_process_delta_time()
		elif held_vector_input == Vector2.ZERO:
			hold_timer = 0.0
		
	return input

## Returns a Vector2 representing input for UI navigation
## like `get_vector_input` but with option to use hold input
## after a certain time threshold.
## If `hold_after_time` is set to zero, it will only check for just pressed actions
func get_vector_input_ui(hold_after_time: float = 0.7) -> Vector2:
	return get_vector_input_base(false, hold_after_time)

## Returns a Vector2 representing user input for movement or directional controls
func get_vector_input() -> Vector2:
	return get_vector_input_base(true, 0.0)

func get_accept_input() -> bool:
	return Input.is_action_just_pressed("interact")

func get_cancel_input() -> bool:
	return Input.is_action_just_pressed("ui_cancel")
