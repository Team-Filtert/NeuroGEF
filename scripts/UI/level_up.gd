class_name LevelUp
extends Node2D

signal done_leveling_up

@export var max_bouns: int

@export var max_health_button: Button
@export var max_mana_button: Button
@export var attack_button: Button
@export var defense_button: Button
@export var speed_button: Button

var max_health_increase: int
var max_mana_increase: int
var attack_increase: int
var defense_increase: int
var speed_increase: int

var random_bonus: int
var level_up_count: int
var next_characters: Array[CombatantData]
var current_character: CombatantData

func _ready() -> void:
	max_health_button.pressed.connect(_on_max_health_pressed)
	max_mana_button.pressed.connect(_on_max_mana_pressed)
	attack_button.pressed.connect(_on_attack_pressed)
	defense_button.pressed.connect(_on_defense_pressed)
	speed_button.pressed.connect(_on_speed_pressed)

func start_level_up(characters: Array[CombatantData]) -> void:
	next_characters = characters
	_level_up_next_character()

func _level_up_next_character() -> void:
	if next_characters.size() > 0:
		current_character = next_characters.pop_back()
		_increase_level()
		_set_stat_increase()
		_setup_ui()
	else:
		done_leveling_up.emit()

func _increase_level() -> void:
	level_up_count = 0
	var xp_requirement: int = CombatManager.get_xp_requirement(current_character.level)
	while current_character.xp >= xp_requirement:
		level_up_count += 1
		current_character.level += 1
		current_character.xp -= xp_requirement
		xp_requirement = CombatManager.get_xp_requirement(current_character.level)

func _set_stat_increase() -> void:
	max_health_increase = current_character.max_health_increase_by_level * level_up_count
	max_mana_increase = current_character.max_mana_increase_by_level * level_up_count
	attack_increase = current_character.base_attack_increase_by_level * level_up_count
	defense_increase = current_character.base_defense_increase_by_level * level_up_count
	speed_increase = current_character.base_speed_increase_by_level * level_up_count

func _setup_ui():
	$Sprite2D.texture = current_character.texture
	_reset_ui()
	
	max_health_button.text = _create_button_text("max health", current_character.max_health, max_health_increase)
	max_mana_button.text = _create_button_text("max mana", current_character.max_mana, max_mana_increase)
	attack_button.text = _create_button_text("attack", current_character.base_attack, attack_increase)
	defense_button.text = _create_button_text("defense", current_character.base_defense, defense_increase)
	speed_button.text = _create_button_text("speed", current_character.base_speed, speed_increase)

func _reset_ui():
	random_bonus = randi_range(1, max_bouns)
	$UI/PanelContainer/VBoxContainer/RandomBonus.text = "select a stat to increase by %d" % random_bonus
	$UI/PanelContainer/VBoxContainer/VBoxMenuHandler.configure_focus()

func _create_button_text(stat_name: String, current_value: int, value_increase: int):
	return "%s: %d + %d" % [stat_name, current_value, value_increase]

func _increase_stats() -> void:
	current_character.max_health += max_health_increase
	current_character.max_mana += max_mana_increase
	current_character.base_attack += max_health_increase
	current_character.base_defense += defense_increase
	current_character.base_speed += speed_increase
	current_character.health = current_character.max_health
	current_character.mana = current_character.max_mana

func _on_max_health_pressed() -> void:
	max_health_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		_reset_ui()
		max_health_button.text = _create_button_text("max health", current_character.max_health, max_health_increase)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_max_mana_pressed() -> void:
	max_mana_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		_reset_ui()
		max_mana_button.text = _create_button_text("max mana", current_character.max_mana, max_mana_increase)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_attack_pressed() -> void:
	attack_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		_reset_ui()
		attack_button.text = _create_button_text("attack", current_character.base_attack, attack_increase)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_defense_pressed() -> void:
	defense_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		_reset_ui()
		defense_button.text = _create_button_text("defense", current_character.base_defense, defense_increase)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_speed_pressed() -> void:
	speed_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		_reset_ui()
		speed_button.text = _create_button_text("speed", current_character.base_speed, speed_increase)
	else:
		_increase_stats()
		_level_up_next_character()
