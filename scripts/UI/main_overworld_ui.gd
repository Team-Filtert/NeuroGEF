extends Control


var is_expanded = false
var input_handler: InputComponent
signal main_ui_interaction_triggered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_handler = InputComponent.new()

	main_ui_interaction_triggered.connect(_on_togle_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if CombatManager.is_in_combat:
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

#func _input(event: InputEvent) -> void:
#	if event is InputEventKey and event.pressed:
#		if event.keycode == KEY_E:
#			if is_expanded:
#				_on_collapse_menu()
#			else:
#				_on_expand_menu()
#		else:
#			_on_collapse_menu()