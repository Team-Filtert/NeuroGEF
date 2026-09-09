extends VBoxContainer

@export var tab_buttons: Array[Button]
@export var tab_container: TabContainer

func _ready() -> void:
	for i in range(tab_buttons.size()):
		tab_buttons[i].pressed.connect(_on_tab_button_pressed.bind(i))

func _on_tab_button_pressed(idx: int) -> void:
	for i in range(tab_buttons.size()):
		if i == idx:
			tab_container.current_tab = i
			tab_buttons[i].theme = preload("res://data/themes/v_tab_button_selected.tres")
		else:
			tab_buttons[i].theme = preload("res://data/themes/v_tab_button.tres")
