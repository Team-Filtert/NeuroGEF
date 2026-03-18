class_name UIInputComponent
extends InputComponent

## Returns a Vector2 representing input for UI navigation
func get_vector_input(event: InputEvent = null) -> Vector2i:
	return get_vector_input_base(false, event)

