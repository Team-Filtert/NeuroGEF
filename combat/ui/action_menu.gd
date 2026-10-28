class_name ActionMenu
extends Control

## Battle command UI: the 3x2 grid and the Skills/Combos/Items action lists.
## [ArenaUI] owns the actor/info panels and forwards menu requests here.

signal message_requested(text: String)

const TAB_NAMES: Array[String] = ["Skills", "Combos", "Items"]

@onready var _grid: GridContainer = $Grid
@onready var _attack_button: Button = $Grid/Attack
@onready var _inspect_button: Button = $Grid/Inspect
@onready var _flee_button: Button = $Grid/Flee
@onready var _tab_view: ActionTabs = $TabView
@onready var _back_button: Button = $TabView/TabButtons/Back
@onready var _tab_container: TabContainer = $TabView/Actions
@onready var _lists: Array[VBoxContainer] = [
	$TabView/Actions/SkillsScroll/Skills as VBoxContainer,
	$TabView/Actions/CombosScroll/Combos as VBoxContainer,
	$TabView/Actions/ItemsScroll/Items as VBoxContainer,
]

var _on_chosen: Callable
var _on_flee: Callable
var _on_inspect: Callable
var _basic_attack: ActionBase
var _enabled := true
var _mute_inspect_hint := false


func _ready() -> void:
	_grid.visible = false
	_tab_view.visible = false
	_tab_view.tab_selected.connect(_select_tab)
	_back_button.pressed.connect(_show_grid)
	_attack_button.pressed.connect(_on_attack_pressed)
	_inspect_button.pressed.connect(_on_inspect_pressed)
	_flee_button.pressed.connect(_on_flee_pressed)
	for i in TAB_NAMES.size():
		(_grid.get_node(TAB_NAMES[i]) as Button).pressed.connect(_tab_view.select.bind(i))
	for button in _grid.get_children():
		button.mouse_entered.connect(func() -> void:
			if _enabled and (button != _inspect_button or not _mute_inspect_hint):
				message_requested.emit(button.get_meta("hint", ""))
		)
		button.focus_entered.connect(func() -> void:
			if _enabled:
				message_requested.emit(button.get_meta("hint", ""))
		)
	_inspect_button.mouse_exited.connect(func() -> void: _mute_inspect_hint = false)


func show_menu(actions: Array[ActionBase], on_chosen: Callable, on_flee: Callable, on_inspect: Callable) -> void:
	clear_menu()
	_on_chosen = on_chosen
	_on_flee = on_flee
	_on_inspect = on_inspect
	_basic_attack = _find_basic_attack(actions)
	_attack_button.disabled = _basic_attack == null
	_attack_button.set_meta("hint", _action_description(_basic_attack) if _basic_attack else "No basic attack available.")
	for action in actions:
		_list_for(action).add_child(_make_action_button(action))
	for list in _lists:
		_limit_focus(list)
	_show_grid()


func clear_menu() -> void:
	_enabled = true
	_mute_inspect_hint = false
	for list in _lists:
		for child in list.get_children():
			list.remove_child(child)
			child.queue_free()
	_grid.visible = false
	_tab_view.visible = false
	_tab_view.clear_selection()
	for button in find_children("*", "Button", true, false):
		button.disabled = false


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	for button in find_children("*", "Button", true, false):
		button.disabled = not enabled
	if not enabled:
		var focused := get_viewport().gui_get_focus_owner()
		if focused:
			focused.release_focus()
		return
	_attack_button.disabled = _basic_attack == null
	if _tab_view.visible:
		_focus_first(_lists[_tab_container.current_tab].get_children())
	else:
		_focus_first(_grid.get_children())


func _show_grid() -> void:
	_grid.visible = true
	_tab_view.visible = false
	_tab_view.clear_selection()
	message_requested.emit("Choose a command.")
	_focus_first(_grid.get_children())


func _select_tab(index: int) -> void:
	_grid.visible = false
	_tab_view.visible = true
	_tab_container.current_tab = index
	var list := _lists[index]
	if list.get_child_count() == 0:
		message_requested.emit("No %s." % TAB_NAMES[index].to_lower())
		_back_button.call_deferred("grab_focus")
		return
	message_requested.emit("%s — choose an action." % TAB_NAMES[index])
	_focus_first(list.get_children())


func _on_attack_pressed() -> void:
	if _basic_attack != null and _on_chosen.is_valid():
		_on_chosen.call(_basic_attack)


func _on_inspect_pressed() -> void:
	_mute_inspect_hint = true
	if _on_inspect.is_valid():
		_on_inspect.call()


func _on_flee_pressed() -> void:
	if _on_flee.is_valid():
		_on_flee.call()


func _make_action_button(action: ActionBase) -> Button:
	var button := Button.new()
	button.text = String(action.display_name)
	button.clip_text = true
	button.pressed.connect(_on_chosen.bind(action))
	var description := _action_description(action)
	button.mouse_entered.connect(func() -> void: message_requested.emit(description))
	button.focus_entered.connect(func() -> void: message_requested.emit(description))
	return button


func _list_for(action: ActionBase) -> VBoxContainer:
	if action is Combo:
		return _lists[1]
	if action is ItemAction:
		return _lists[2]
	return _lists[0]


func _limit_focus(list: VBoxContainer) -> void:
	var buttons := list.get_children()
	if buttons.is_empty():
		return
	(buttons[0] as Button).focus_neighbor_top = buttons[0].get_path_to(buttons[0])
	(buttons[-1] as Button).focus_neighbor_bottom = buttons[-1].get_path_to(buttons[-1])


func _focus_first(controls) -> void:
	for control in controls:
		if control is Button and not control.disabled and control.is_visible_in_tree():
			control.call_deferred("grab_focus")
			return


func _find_basic_attack(actions: Array[ActionBase]) -> ActionBase:
	for action in actions:
		if action.display_name == &"Basic Attack":
			return action
	for action in actions:
		if action.type == ActionBase.Type.ATTACK and action.mana_cost == 0:
			return action
	return null


func _action_description(action: ActionBase) -> String:
	var text := action.description if not action.description.is_empty() else String(action.display_name)
	if action.mana_cost > 0:
		text += "\nMP: %d" % action.mana_cost
	return text


func _unhandled_input(event: InputEvent) -> void:
	if _enabled and _tab_view.visible and event.is_action_pressed(&"ui_cancel"):
		_show_grid()
		get_viewport().set_input_as_handled()
