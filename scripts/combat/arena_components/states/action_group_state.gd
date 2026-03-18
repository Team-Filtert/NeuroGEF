class_name ActionGroupState extends ArenaStateBase

@export var attack_button: Button
@export var block_button: Button
@export var flee_button: Button

@export var attack_action_select_state: ActionSelectState
@export var skill_action_select_state: ActionSelectState
@export var items_action_select_state: ActionSelectState

func connect_button(button: Button, event: Callable):
	if not button.pressed.is_connected(event):
		button.pressed.connect(event)

func enter():
	connect_button(attack_button, _on_attack_pressed)
	connect_button(block_button, _on_block_pressed)
	connect_button(flee_button, _on_flee_pressed)

	parent.ui_manager.reset_main_menu()

func _on_attack_pressed():
	parent.change_state(attack_action_select_state)

func _on_block_pressed():
	pass
	
func _on_flee_pressed() -> void:
	# For later, implement flee chance based on something
	parent.end_battle()