extends Control


var is_expanded = false
var input_handler: InputComponent
signal main_ui_interaction_triggered

func _ready() -> void:
	input_handler = InputComponent.new()

	main_ui_interaction_triggered.connect(_on_togle_menu)


func _process(_delta: float) -> void:
	if GameManager.combat_manager.is_in_combat:
		hide()
	elif is_expanded:
		show()
		
			
func _unhandled_input(event: InputEvent) -> void:
	if input_handler.get_cancel_input(event):
		main_ui_interaction_triggered.emit()

func _on_togle_menu():
	if is_expanded:
		is_expanded = false
		hide()
	else:
		is_expanded = true
		show()
