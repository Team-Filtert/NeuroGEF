class_name UIInputComponent
extends InputComponent

## Returns a Vector2 representing input for UI navigation
func get_vector_input(event: InputEvent = null) -> Vector2i:
	return get_vector_input_base(false, event)

func get_pause_input(event: InputEvent = null) -> bool:
	if event:
		return event.is_action_pressed("pause")
	return Input.is_action_pressed("pause")
