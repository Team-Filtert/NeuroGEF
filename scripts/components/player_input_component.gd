class_name PlayerInputComponent
extends InputComponent

## Returns a Vector2 representing user input for movement or directional controls
func get_vector_input(event: InputEvent = null) -> Vector2i:
	return get_vector_input_base(true, event)

