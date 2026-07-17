class_name SelectAction
extends ArenaSubstateBase

@export var ui: Control

@export var attack_button: Button
@export var combo_button: Button
@export var item_button: Button
@export var flee_button: Button

@export var attack_menu: VBoxContainer
@export var combo_menu: VBoxContainer
@export var item_menu: VBoxContainer

var callable := func(a: ActionBase, i: int):
	arena.action_que.append(a)
	parent.change_substate(next_substate, i)

func enter(i: int) -> void:
	attack_menu.visible = false
	combo_menu.visible = false
	item_menu.visible = false
	
	ui.visible = true
	
	_set_attacks(i)

func exit() -> void:
	ui.visible = false

func _set_attacks(i: int):
	for child in attack_menu.get_children():
		child.queue_free()
	
	var pm := arena.party_data[i]
	for attack in pm.attacks:
		if attack.mana_cost > pm.mana:
			continue
		
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = attack.display_name
		button.pressed.connect(callable.bind(attack, i))
		attack_menu.add_child(button)

func _on_attack_button_pressed() -> void:
	attack_menu.visible = true
	combo_menu.visible = false
	item_menu.visible = false

func _on_combo_button_pressed() -> void:
	attack_menu.visible = false
	combo_menu.visible = true
	item_menu.visible = false

func _on_item_button_pressed() -> void:
	attack_menu.visible = false
	combo_menu.visible = false
	item_menu.visible = true

func _on_flee_button_pressed() -> void:
	arena.end_battle()
