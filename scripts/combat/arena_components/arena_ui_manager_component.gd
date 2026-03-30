class_name ArenaUIManagerComponent extends Node

@onready var parent: ArenaComponent = get_parent()

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
