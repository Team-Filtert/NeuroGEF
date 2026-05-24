extends Control

@export var main_menu_button: Button
@export var quit_button: Button
@export var handler: MenuHandler

func _ready() -> void:
	assert(main_menu_button, "main_menu_button is not assigned.")
	assert(quit_button, "quit_button is not assigned.")
	assert(handler, "handler is not assigned.")

	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open()

func open() -> void:
	get_tree().paused = true
	show()
	handler.configure_focus()

func close() -> void:
	get_tree().paused = false
	hide()
		
func _on_main_menu_pressed() -> void:
	print("go to main menu")

func _on_quit_pressed() -> void:
	get_tree().quit()
