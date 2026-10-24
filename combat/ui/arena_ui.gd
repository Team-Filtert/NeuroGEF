class_name ArenaUI
extends Control

## Drives the battle UI that already lives in [code]arena.tscn[/code]: the actor
## panel (name + HP/MP), the ult bar, the info panel and the Skills/Combos/Items
## action tabs.
##
## Only two things are created here because the scene didn't have them: a small
## grade popup and the hook the timing challenge mounts into.

@onready var _name_label: Label = $MainBG/Control/Name
@onready var _hp_bar: ProgressBar = $MainBG/Control/StatBars/HP/HPBar
@onready var _hp_label: Label = $MainBG/Control/StatBars/HP/HPBar/HPValueLable
@onready var _mp_bar: ProgressBar = $MainBG/Control/StatBars/MP/MPBar
@onready var _mp_label: Label = $MainBG/Control/StatBars/MP/MPBar/MPValueLable
@onready var _ult_bar: ProgressBar = $UltBar
@onready var _boss_ult_label: Label = $BossUltLabel
@onready var _boss_ult_bar: ProgressBar = $BossUltBar
@onready var _info_label: Label = $InfoBG/MarginContainer/Label
@onready var _actions: TabContainer = $MainBG/Control/ActionTabs/Actions
@onready var _skills_tab: VBoxContainer = $MainBG/Control/ActionTabs/Actions/Attack
@onready var _combos_tab: VBoxContainer = $MainBG/Control/ActionTabs/Actions/Combo
@onready var _items_tab: VBoxContainer = $MainBG/Control/ActionTabs/Actions/Item

## Where timing challenges (the QTE) mount themselves.
@onready var timing_host: Control = $TimingHost
@onready var _grade_label: Label = $GradeLabel
@onready var _level_up_panel: Control = $LevelUpPanel
@onready var _level_up_entries: Label = $LevelUpPanel/Panel/Margin/VBox/Entries


func _ready() -> void:
	_info_label.text = ""
	_grade_label.modulate.a = 0.0
	_level_up_panel.visible = false


#region ACTION MENU

func show_action_menu(actions: Array[ActionBase], on_chosen: Callable, on_flee: Callable) -> void:
	clear_action_menu()

	for action in actions:
		var button := Button.new()
		button.text = _action_text(action)
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(on_chosen.bind(action))
		# Show what the action does in the info panel while it is highlighted.
		button.mouse_entered.connect(show_message.bind(_action_description(action)))
		button.focus_entered.connect(show_message.bind(_action_description(action)))
		_tab_for(action).add_child(button)

	var flee := Button.new()
	flee.text = "Flee"
	flee.add_theme_font_size_override("font_size", 10)
	flee.pressed.connect(on_flee)
	_skills_tab.add_child(flee)

	_focus_current_tab()


func clear_action_menu() -> void:
	for tab in [_skills_tab, _combos_tab, _items_tab]:
		for child in tab.get_children():
			tab.remove_child(child)
			child.queue_free()

#endregion


#region INFO

func set_actor(actor: Combatant) -> void:
	_name_label.text = actor.get_display_name()
	_hp_bar.max_value = actor.get_max_health()
	_hp_bar.value = actor.get_health()
	_hp_label.text = "%d/%d" % [actor.get_health(), actor.get_max_health()]
	_mp_bar.max_value = actor.get_max_mana()
	_mp_bar.value = actor.get_mana()
	_mp_label.text = "%d/%d" % [actor.get_mana(), actor.get_max_mana()]


func refresh_all(combatants: Array) -> void:
	for combatant in combatants:
		if is_instance_valid(combatant):
			(combatant as Combatant).refresh()


func show_message(text: String) -> void:
	_info_label.text = text


func show_grade(grade: int) -> void:
	_grade_label.text = TimingGrade.label(grade)
	_grade_label.modulate = _grade_color(grade)
	_grade_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(_grade_label, "modulate:a", 0.0, 0.3)

#endregion


#region ULT

func setup_ult(max_party: int, max_boss: int, is_boss: bool) -> void:
	_ult_bar.max_value = maxi(max_party, 1)
	_ult_bar.value = 0
	_boss_ult_bar.max_value = maxi(max_boss, 1)
	_boss_ult_bar.value = 0
	_boss_ult_bar.visible = is_boss
	_boss_ult_label.visible = is_boss


func update_ult(charge: int, is_boss: bool) -> void:
	if is_boss:
		_boss_ult_bar.value = charge
	else:
		_ult_bar.value = charge

#endregion


#region LEVEL UP

## Shows the per-member level-up summary returned by the arena. Lines come from
## the [code]{name, level, gains}[/code] dictionaries [Leveling] produces.
func show_level_ups(entries: Array) -> void:
	var lines: Array[String] = []
	for entry in entries:
		lines.append(_level_up_line(entry))
	_level_up_entries.text = "\n".join(lines)
	_level_up_panel.visible = true


func _level_up_line(entry: Dictionary) -> String:
	var gains: Array[String] = []
	for stat in entry.get("gains", {}):
		gains.append("+%d %s" % [entry["gains"][stat], String(stat).replace("_", " ")])
	return "%s  ->  Lv %d    %s" % [entry.get("name", "?"), entry.get("level", 1), ", ".join(gains)]

#endregion


#region FLOW

func show_banner(text: String) -> void:
	show_message(text)
	await get_tree().create_timer(0.4).timeout


func wait_for_accept() -> void:
	await get_tree().process_frame
	while not (Input.is_action_just_pressed(&"ui_accept") or Input.is_action_just_pressed(&"interact")):
		await get_tree().process_frame

#endregion


func _tab_for(action: ActionBase) -> VBoxContainer:
	if action is Combo:
		return _combos_tab
	if action is ItemAction:
		return _items_tab
	return _skills_tab


## Switches to the first tab that has buttons and focuses it.
func _focus_current_tab() -> void:
	for i in _actions.get_child_count():
		var tab := _actions.get_child(i) as Control
		if tab.get_child_count() > 0:
			_actions.current_tab = i
			_grab_focus.call_deferred(tab.get_child(0))
			return


func _grab_focus(control: Node) -> void:
	if is_instance_valid(control) and control.is_inside_tree():
		(control as Control).grab_focus()


func _action_text(action: ActionBase) -> String:
	var text := String(action.display_name)
	if action.mana_cost > 0:
		text += "  (%d MP)" % action.mana_cost
	return text


func _action_description(action: ActionBase) -> String:
	if not action.description.is_empty():
		return action.description
	return String(action.display_name)


func _grade_color(grade: int) -> Color:
	return TimingGrade.color(grade)
