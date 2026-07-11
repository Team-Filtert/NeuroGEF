class_name ActionGroupState
extends ArenaStateBase

@export var attack_button: Button
@export var combo_button: Button
@export var items_button: Button
@export var flee_button: Button

@export var attack_action_select_state: ActionSelectStateBase
@export var skill_action_select_state: ActionSelectStateBase
@export var items_action_select_state: ActionSelectStateBase

func enter():
	connect_button(attack_button, _on_attack_pressed)
	connect_button(combo_button, _on_combo_pressed)
	connect_button(items_button, _on_items_pressed)
	connect_button(flee_button, _on_flee_pressed)

func connect_button(button: Button, event: Callable):
	if not button.pressed.is_connected(event):
		button.pressed.connect(event)

func _on_attack_pressed():
	parent.change_state(attack_action_select_state)

func _on_combo_pressed():
	parent.change_state(skill_action_select_state)

func _on_items_pressed():
	parent.change_state(items_action_select_state)
	
func _on_flee_pressed() -> void:
	parent.end_battle(false)
