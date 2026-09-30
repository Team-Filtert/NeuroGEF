extends HBoxContainer

@export var tab_container: TabContainer
@export var tab_buttons: Array[Button]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, 3):
		tab_buttons[i].pressed.connect(change_tab.bind(i))

func change_tab(tab_idx: int):
	tab_container.current_tab = tab_idx
	for i in range(0, 3):
		tab_buttons[i].theme = null
	tab_buttons[tab_idx].theme = preload("res://data/themes/action_tabs_theme_selected.tres")
