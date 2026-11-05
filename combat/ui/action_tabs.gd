class_name ActionTabs
extends HBoxContainer

## Tab selector for the battle action menu. Emits [signal tab_selected] and
## highlights the active button; [ArenaUI] swaps the action list contents.

signal tab_selected(index: int)

const SELECTED_THEME := preload("res://data/themes/action_tabs_theme_selected.tres")

@export var tab_buttons: Array[Button]


func _ready() -> void:
	for i in tab_buttons.size():
		tab_buttons[i].pressed.connect(select.bind(i))


func select(index: int) -> void:
	for i in tab_buttons.size():
		tab_buttons[i].theme = SELECTED_THEME if i == index else null
	tab_selected.emit(index)


func clear_selection() -> void:
	for button in tab_buttons:
		button.theme = null
