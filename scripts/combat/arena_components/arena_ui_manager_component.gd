class_name ArenaUIManagerComponent
extends Node

@onready var parent: ArenaComponent = get_parent()
@onready var arena: Arena = parent.get_parent()

@export var ult_display: UltDisplayHandler
@export var main_combat_menu: MenuHandler

func reset_main_menu():
	setup_menus_for_current_character()
	main_combat_menu.configure_focus()
	parent.get_current_combatant().set_selected(true)

func setup_menus_for_current_character():
	for state in parent.states:
		if state is ActionSelectState:
			state.setup_menu_for_current_character()

func hide_all_submenus():
	for state in parent.states:
		if state is ActionSelectState:
			state.menu_handler.parent.visible = false

func setup_ult_display():
	ult_display.setup(arena.party_ult_charge,  arena.max_party_ult_charge,
			arena.max_boss_ult_charge, parent.is_boss)

func update_ult_display(is_boss: bool):
	if is_boss:
		ult_display.update(arena.boss_ult_charge, true)
	else:
		ult_display.update(arena.party_ult_charge, false)
