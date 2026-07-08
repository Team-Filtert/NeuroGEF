extends Control

var is_expanded := false
var input_handler: InputComponent

var is_in_main_menu := false
var is_in_save_menu := false
var is_in_level_up := false
var is_in_combat := false

func _ready() -> void:
	input_handler = InputComponent.new()
	# CombatLayer/LevelUpLayer used to be static siblings in root.tscn wired
	# via scene connections; both are built at runtime now (see
	# combat_manager.gd/level_up_manager.gd), so this UI reaches out to the
	# autoloads instead of the other way around.
	CombatManager.combat_layer.visibility_changed.connect(_on_combat_layer_visibility_changed)
	LevelUpManager.level_up_layer.visibility_changed.connect(_on_level_up_layer_visibility_changed)

func _unhandled_input(event: InputEvent) -> void:
	if input_handler.get_cancel_input(event) and _is_in_overworld():
		_togle_menu()

func _is_in_overworld() -> bool:
	return not (is_in_main_menu or is_in_save_menu or is_in_level_up or is_in_combat)

func _togle_menu() -> void:
	if is_expanded:
		is_expanded = false
		hide()
	else:
		is_expanded = true
		show()

func _update_is_in_layer(is_in_layer: bool) -> bool:
	if not is_in_layer:
		hide()
		return true
	elif is_expanded:
		show()
		return false
	else:
		return false

func _on_main_buttons_visibility_changed() -> void:
	is_in_main_menu = _update_is_in_layer(is_in_main_menu)

func _on_save_menu_visibility_changed() -> void:
	is_in_save_menu = _update_is_in_layer(is_in_save_menu)

func _on_combat_layer_visibility_changed() -> void:
	is_in_combat = _update_is_in_layer(is_in_combat)

func _on_level_up_layer_visibility_changed() -> void:
	is_in_level_up = _update_is_in_layer(is_in_level_up)
