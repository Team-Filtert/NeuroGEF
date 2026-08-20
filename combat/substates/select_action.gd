class_name SelectAction
extends ArenaSubstateBase

@export var ui: Control

@export var name_lable: Label
@export var attack_lable: Label
@export var magic_lable: Label
@export var defense_lable: Label
@export var speed_lable: Label
@export var accuracy_lable: Label

@export var attack_menu: VBoxContainer
@export var combo_menu: VBoxContainer
@export var item_menu: VBoxContainer

var callable := func(a: ActionBase, i: int):
	arena.action_que.append(a)
	parent.change_substate(next_substate, i)

func enter(i: int) -> void:
	ui.visible = true
	
	_set_attacks(i)
	_set_combos(i)
	_set_items(i)

func exit() -> void:
	ui.visible = false

func _set_labels(i: int):
	var pm := arena.party_data[i]
	
	name_lable.text = pm.display_name
	attack_lable.text = "Attack: %d" % pm.attack
	attack_lable.text = "Magic: %d" % pm.magic
	attack_lable.text = "Defense: %d" % pm.defense
	attack_lable.text = "Speed: %d" % pm.speed
	attack_lable.text = "Accuracy: %d" % pm.accuracy

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

func _set_combos(i: int):
	for child in combo_menu.get_children():
		child.queue_free()
	
	var pm := arena.party_data[i]
	for combo in arena.combos:
		var combo_names := combo.combatants_display_names
		if combo_names.all(func(n): return arena.party_data.any(func(p): return p.display_name == n)) \
				and combo_names.any(func(n): return n == pm.display_name):
			continue
		
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = combo.display_name
		button.pressed.connect(callable.bind(combo, i))
		attack_menu.add_child(button)

func _set_items(i: int):
	for child in item_menu.get_children():
		child.queue_free()
	
	var pm := arena.party_data[i]
