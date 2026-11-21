class_name LevelUpPanel
extends Control

## Victory level-up modal. Shows the automatic gains and, Mario & Luigi style,
## lets the player pick one bonus stat per level, then stop a spinning number.

signal choices_finished

const UI_FONT := preload("res://assets/first_coffee_+.otf")
const ROULETTE_TICK := 0.06
const RESULT_PAUSE := 0.35

@onready var _entries: Label = $Center/Panel/Margin/VBox/Entries
@onready var _prompt: Label = $Center/Panel/Margin/VBox/Prompt
@onready var _choices: GridContainer = $Center/Panel/Margin/VBox/Choices
@onready var _roulette: Label = $Center/Panel/Margin/VBox/Roulette
@onready var _stop_button: Button = $Center/Panel/Margin/VBox/Stop
@onready var _hint: Label = $Center/Panel/Margin/VBox/Hint

var _entries_data: Array = []
var _pending: Array = []
var _current: Dictionary = {}
var _roulette_active := false
var _roulette_tick := 0.0
var _roulette_choice: Dictionary = {}


func _ready() -> void:
	_stop_button.pressed.connect(_stop_roulette)
	_hide_roulette()


func present(entries: Array) -> void:
	_entries_data = entries
	_pending.clear()
	_current = {}
	for entry in entries:
		var levels := int(entry.get("levels", 0))
		if levels > 0 and entry.get("member") is PartyMember:
			_pending.append({"entry": entry, "remaining": levels})

	_refresh_summary()
	_clear_choices()
	_hide_roulette()
	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

	if _pending.is_empty():
		_prompt.text = ""
		_hint.text = "press accept to continue"
		return

	_show_next_choice()


func has_choices() -> bool:
	return not _pending.is_empty() or not _current.is_empty()


func _show_next_choice() -> void:
	if _pending.is_empty():
		_finish_choices()
		return

	_current = _pending[0]
	var entry: Dictionary = _current["entry"]
	var remaining := int(_current["remaining"])
	_prompt.text = "Choose a bonus for %s" % entry.get("name", "?")
	if remaining > 1:
		_prompt.text += "  (%d left)" % remaining
	_hide_roulette()
	_build_choice_buttons()


func _build_choice_buttons() -> void:
	_clear_choices()
	for choice in Leveling.BONUS_CHOICES:
		var button := Button.new()
		button.text = String(choice["label"])
		button.custom_minimum_size = Vector2(0, 22)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_override(&"font", UI_FONT)
		button.add_theme_font_size_override(&"font_size", 10)
		button.pressed.connect(_start_roulette.bind(choice))
		_choices.add_child(button)
	_choices.visible = true
	_hint.text = "choose a stat, then stop the number"
	var first := _choices.get_child(0) as Button
	if first != null:
		first.call_deferred("grab_focus")


func _start_roulette(choice: Dictionary) -> void:
	_roulette_choice = choice
	_roulette_active = true
	_roulette_tick = 0.0
	_clear_choices()
	var entry: Dictionary = _current.get("entry", {})
	_prompt.text = "%s: %s — press to stop!" % [entry.get("name", "?"), choice["label"]]
	_roulette.text = str(_random_amount())
	_roulette.visible = true
	_stop_button.visible = true
	_stop_button.disabled = false
	_hint.text = "press accept or click STOP"
	set_process(true)
	_stop_button.call_deferred("grab_focus")


func _process(delta: float) -> void:
	if not _roulette_active:
		return
	_roulette_tick += delta
	if _roulette_tick >= ROULETTE_TICK:
		_roulette_tick = 0.0
		_roulette.text = str(_random_amount())


func _random_amount() -> int:
	return randi_range(int(_roulette_choice.get("min", 1)), int(_roulette_choice.get("max", 1)))


func _unhandled_input(event: InputEvent) -> void:
	if not _roulette_active:
		return
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"interact"):
		_stop_roulette()
		get_viewport().set_input_as_handled()


func _stop_roulette() -> void:
	if not _roulette_active:
		return
	_roulette_active = false
	set_process(false)
	var amount := int(_roulette.text)
	_stop_button.disabled = true
	var entry: Dictionary = _current.get("entry", {})
	_prompt.text = "%s: +%d %s!" % [entry.get("name", "?"), amount, _roulette_choice.get("label", "")]
	_hint.text = ""
	await get_tree().create_timer(RESULT_PAUSE).timeout
	_hide_roulette()
	_apply_choice(_roulette_choice, amount)


func _apply_choice(choice: Dictionary, amount: int) -> void:
	var entry: Dictionary = _current.get("entry", {})
	var member := entry.get("member") as PartyMember
	if member == null:
		return

	Leveling.apply_bonus(member, String(choice["stat"]), amount)
	var chosen: Array = entry.get("chosen_bonuses", [])
	chosen.append("+%d %s" % [amount, choice["label"]])
	entry["chosen_bonuses"] = chosen

	_current["remaining"] = int(_current.get("remaining", 1)) - 1
	_refresh_summary()

	if int(_current["remaining"]) > 0:
		_show_next_choice()
		return

	_pending.pop_front()
	if _pending.is_empty():
		_finish_choices()
	else:
		_show_next_choice()


func _finish_choices() -> void:
	_current = {}
	_clear_choices()
	_hide_roulette()
	_prompt.text = ""
	_hint.text = "press accept to continue"
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	choices_finished.emit()


func _hide_roulette() -> void:
	_roulette_active = false
	set_process(false)
	_roulette.visible = false
	_stop_button.visible = false


func _clear_choices() -> void:
	_choices.visible = false
	for child in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()


func _refresh_summary() -> void:
	var lines: Array[String] = []
	for entry in _entries_data:
		var line := _line_for(entry)
		var chosen: Array = entry.get("chosen_bonuses", [])
		if not chosen.is_empty():
			line += "    [%s]" % ", ".join(chosen)
		lines.append(line)
	_entries.text = "\n".join(lines)


func _line_for(entry: Dictionary) -> String:
	var gain_names: Array = entry.get("gains", {}).keys()
	gain_names.sort()
	var gains: Array[String] = []
	for stat in gain_names:
		gains.append("+%d %s" % [entry["gains"][stat], String(stat).replace("_", " ")])
	var gain_text := ", ".join(gains) if not gains.is_empty() else "No stat gains"
	return "%s  ->  Lv %d    %s" % [entry.get("name", "?"), entry.get("level", 1), gain_text]
