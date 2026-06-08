extends Control
class_name MainMenu

@export var play_button: Button
@export var options_button: Button
@export var quit_button: Button

@export var main_menu_handler: MenuHandler

@export var save_menu_handler: MenuHandler

func _ready():
	play_button.pressed.connect(handle_play_button)
	options_button.pressed.connect(handle_option_button)
	quit_button.pressed.connect(handle_quit_button)

	main_menu_handler.configure_focus()
	save_menu_handler.input_handler.got_cancel_input.connect(go_to_main_buttons.bind(save_menu_handler))

func go_to_main_buttons(cur_handler: MenuHandler):
	if not cur_handler.parent.visible:
		return
	
	cur_handler.parent.visible = false
	main_menu_handler.parent.visible = true
	main_menu_handler.configure_focus()

func handle_play_button():
	main_menu_handler.parent.visible = false
	save_menu_handler.parent.visible = true
	save_menu_handler.configure_focus()

func handle_option_button():
	pass

func handle_quit_button():
	get_tree().quit()
