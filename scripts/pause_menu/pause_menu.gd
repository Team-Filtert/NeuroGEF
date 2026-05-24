extends Control

@export var main_menu_button: Button
@export var quit_button: Button
@export var menu_handler: MenuHandler
@export var input_component: UIInputComponent

func _ready() -> void:
	assert(main_menu_button, "main_menu_button is not assigned.")
	assert(quit_button, "quit_button is not assigned.")
	assert(menu_handler, "menu_handler is not assigned.")
	assert(input_component, "input_component is not assigned")

	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if input_component.get_pause_input(event):
		if visible:
			close()
		else:
			open()

func open() -> void:
	get_tree().paused = true
	show()
	menu_handler.configure_focus()

func close() -> void:
	get_tree().paused = false
	hide()
		
func _on_main_menu_pressed() -> void:
	print("go to main menu")

func _on_quit_pressed() -> void:
	get_tree().quit()
