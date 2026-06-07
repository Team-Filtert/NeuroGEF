class_name PlayerInputComponent
extends InputComponent

## Returns a Vector2 representing user input for movement or directional controls
func get_vector_input(event: InputEvent = null) -> Vector2i:
	return get_vector_input_base(true, event)

func is_sprinting(event: InputEvent = null) -> bool:
	if event:
		return event.is_action_pressed("sprint")
	return Input.is_action_pressed("sprint")
