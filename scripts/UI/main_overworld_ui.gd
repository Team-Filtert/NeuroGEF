extends Control

var is_expanded := false
var input_handler: InputComponent

func _ready() -> void:
	input_handler = InputComponent.new()
	GameManager.state_changed.connect(_on_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if input_handler.get_cancel_input(event) and GameManager.is_in_overworld():
		_toggle_menu()

func _toggle_menu() -> void:
	if is_expanded:
		is_expanded = false
		hide()
	else:
		is_expanded = true
		show()

func _on_state_changed(_new_state: GameManager.State) -> void:
	if GameManager.is_in_overworld() and is_expanded:
		show()
	else:
		hide()