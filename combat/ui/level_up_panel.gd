class_name LevelUpPanel
extends Control

## Victory level-up modal. Shows the automatic gains and, Mario & Luigi style,
## lets the player pick one bonus stat per level.

signal choices_finished

const UI_FONT := preload("res://assets/first_coffee_+.otf")

@onready var _entries: Label = $Center/Panel/Margin/VBox/Entries
@onready var _prompt: Label = $Center/Panel/Margin/VBox/Prompt
@onready var _choices: GridContainer = $Center/Panel/Margin/VBox/Choices
@onready var _hint: Label = $Center/Panel/Margin/VBox/Hint

var _entries_data: Array = []
var _pending: Array = []
var _current: Dictionary = {}


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
	_build_choice_buttons()


func _build_choice_buttons() -> void:
	_clear_choices()
	for choice in Leveling.BONUS_CHOICES:
		var button := Button.new()
		button.text = "+%d %s" % [choice["amount"], choice["label"]]
		button.custom_minimum_size = Vector2(0, 22)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_override(&"font", UI_FONT)
		button.add_theme_font_size_override(&"font_size", 10)
		button.pressed.connect(_on_bonus_chosen.bind(choice))
		_choices.add_child(button)
	_choices.visible = true
	_hint.text = "choose with the keyboard or mouse"
	var first := _choices.get_child(0) as Button
	if first != null:
		first.call_deferred("grab_focus")


func _clear_choices() -> void:
	_choices.visible = false
	for child in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()


func _on_bonus_chosen(choice: Dictionary) -> void:
	var entry: Dictionary = _current.get("entry", {})
	var member := entry.get("member") as PartyMember
	if member == null:
		return

	Leveling.apply_bonus(member, String(choice["stat"]), int(choice["amount"]))
	var chosen: Array = entry.get("chosen_bonuses", [])
	chosen.append("+%d %s" % [choice["amount"], choice["label"]])
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
	_prompt.text = ""
	_hint.text = "press accept to continue"
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	choices_finished.emit()


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
