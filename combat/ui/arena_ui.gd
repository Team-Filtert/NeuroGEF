class_name ArenaUI
extends Control

## Drives the battle HUD in [code]arena.tscn[/code]: actor panel, ult bars, info
## panel, grade popup and level-up overlay. The command grid and action lists
## live in [ActionMenu].

@onready var _name_label: Label = $MainBG/Control/Name
@onready var _hp_bar: ProgressBar = $MainBG/Control/StatBars/HP/HPBar
@onready var _hp_label: Label = $MainBG/Control/StatBars/HP/HPBar/HPValueLable
@onready var _mp_bar: ProgressBar = $MainBG/Control/StatBars/MP/MPBar
@onready var _mp_label: Label = $MainBG/Control/StatBars/MP/MPBar/MPValueLable
@onready var _ult_bar: ProgressBar = $UltBar
@onready var _boss_ult_label: Label = $BossUltLabel
@onready var _boss_ult_bar: ProgressBar = $BossUltBar
@onready var _info_panel: PanelContainer = $InfoBG
@onready var _info_label: Label = $InfoBG/MarginContainer/Label
@onready var _menu: ActionMenu = $MainBG/Control/ActionMenu

## Where timing challenges (the QTE) mount themselves.
@onready var timing_host: Control = $TimingHost
@onready var _grade_label: Label = $GradeLabel
@onready var _level_up_panel: Control = $LevelUpPanel
@onready var _level_up_entries: Label = $LevelUpPanel/Panel/Margin/VBox/Entries


func _ready() -> void:
	_info_label.text = ""
	_grade_label.modulate.a = 0.0
	_level_up_panel.visible = false
	_menu.message_requested.connect(show_message)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_info"):
		_info_panel.visible = not _info_panel.visible
		get_viewport().set_input_as_handled()


#region ACTION MENU

func show_action_menu(actions: Array[ActionBase], on_chosen: Callable, on_flee: Callable, on_inspect: Callable) -> void:
	_menu.show_menu(actions, on_chosen, on_flee, on_inspect)


func clear_action_menu() -> void:
	_menu.clear_menu()


func set_action_menu_enabled(enabled: bool) -> void:
	_menu.set_enabled(enabled)

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


func show_combatant_info(combatant: Combatant) -> void:
	var lines: Array[String] = [
		combatant.get_display_name(),
		"HP %d/%d    MP %d/%d" % [
			combatant.get_health(), combatant.get_max_health(),
			combatant.get_mana(), combatant.get_max_mana(),
		],
		"ATK %d    DEF %d    SPD %d" % [
			combatant.get_attack(), combatant.get_defense(), combatant.get_speed(),
		],
	]
	if not combatant.status_effects.is_empty():
		var statuses: Array[String] = []
		for effect in combatant.status_effects:
			statuses.append(String(effect.display_name))
		lines.append("Status: %s" % ", ".join(statuses))
	show_message("\n".join(lines))


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


func _grade_color(grade: int) -> Color:
	return TimingGrade.color(grade)
