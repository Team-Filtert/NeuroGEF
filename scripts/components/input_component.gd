class_name InputComponent
extends Node

signal got_cancel_input()
signal got_accept_input()

func get_held_vector_input(event: InputEvent = null) -> Vector2:
	var input := Vector2.ZERO
	if event:
		if event.is_action_pressed("ui_up"):
			input += Vector2.UP
		if event.is_action_pressed("ui_down"):
			input += Vector2.DOWN
		if event.is_action_pressed("ui_left"):
			input += Vector2.LEFT
		if event.is_action_pressed("ui_right"):
			input += Vector2.RIGHT
		return input
	else:
		if Input.is_action_pressed("ui_up"):
			input += Vector2.UP
		if Input.is_action_pressed("ui_down"):
			input += Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			input += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			input += Vector2.RIGHT
		return input

func get_just_pressed_vector_input(event: InputEvent = null) -> Vector2:
	var input := Vector2.ZERO
	if event:
		if event.is_action_pressed("ui_up"):
			input += Vector2.UP
		if event.is_action_pressed("ui_down"):
			input += Vector2.DOWN
		if event.is_action_pressed("ui_left"):
			input += Vector2.LEFT
		if event.is_action_pressed("ui_right"):
			input += Vector2.RIGHT
		return input
	else:
		if Input.is_action_just_pressed("ui_up"):
			input += Vector2.UP
		if Input.is_action_just_pressed("ui_down"):
			input += Vector2.DOWN
		if Input.is_action_just_pressed("ui_left"):
			input += Vector2.LEFT
		if Input.is_action_just_pressed("ui_right"):
			input += Vector2.RIGHT
		return input

## Returns a Vector2 representing the directional input based on the defined actions.
## If `action_held` is true, it checks for actions being held down; otherwise, 
## it checks for just pressed actions.
func get_vector_input_base(action_held: bool, event: InputEvent = null) -> Vector2:
	var input := Vector2.ZERO

	var held_vector_input := get_held_vector_input(event)
	var just_pressed_vector_input := get_just_pressed_vector_input(event)
	
	if action_held:
		input += held_vector_input
	else:
		input += just_pressed_vector_input
		
		
	return input

func get_accept_input(event: InputEvent = null) -> bool:
	if event:
		return event.is_action_pressed("ui_accept")
	return Input.is_action_just_pressed("ui_accept")

func get_cancel_input(event: InputEvent = null) -> bool:
	if event:
		return event.is_action_pressed("ui_cancel")
	return Input.is_action_just_pressed("ui_cancel")

func get_interact_input(event: InputEvent = null) -> bool:
	return get_accept_input(event)

func _input(event: InputEvent):
	if get_cancel_input(event):
		got_cancel_input.emit()
		return
	if get_accept_input(event):
		got_accept_input.emit()
		return

# Virtual method
func get_vector_input() -> Vector2i:
	return Vector2i.ZERO