extends HBoxContainer

## Tab selector for the battle action menu. Switches which action category the
## [TabContainer] shows and highlights the active tab button.

@export var tab_container: TabContainer
@export var tab_buttons: Array[Button]


func _ready() -> void:
	for i in range(0, 3):
		tab_buttons[i].pressed.connect(change_tab.bind(i))


func change_tab(tab_idx: int) -> void:
	tab_container.current_tab = tab_idx
	for i in range(0, 3):
		tab_buttons[i].theme = null
	tab_buttons[tab_idx].theme = preload("res://data/themes/action_tabs_theme_selected.tres")
