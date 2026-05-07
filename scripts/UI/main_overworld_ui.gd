extends Control

var is_expanded := false
var input_handler: InputComponent

func _ready() -> void:
	input_handler = InputComponent.new()

func _unhandled_input(event: InputEvent) -> void:
	if input_handler.get_cancel_input(event) and not CombatManager.is_in_combat:
		_togle_menu()

func _togle_menu():
	if is_expanded:
		is_expanded = false
		hide()
	else:
		is_expanded = true
		show()

func _on_combat_layer_visibility_changed() -> void:
	if CombatManager.is_in_combat:
		hide()
	elif is_expanded:
		show()
