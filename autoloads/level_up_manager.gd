extends Node

signal done_leveling_up

enum Stat {
	MAX_HEALTH,
	MAX_MANA,
	ATTACK,
	DEFENSE,
	SPEED,
	MAGIC,
	ACCURACY,
}

var level_up_layer: CanvasLayer
var level_up_ui: LevelUpUI

func _ready() -> void:
	level_up_layer = CanvasLayer.new()
	level_up_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	level_up_layer.visible = false
	add_child(level_up_layer)

	level_up_ui = preload("res://ui/level_up_ui.tscn").instantiate()
	level_up_layer.add_child(level_up_ui)

var min_bonus := 1
var max_bouns := 3

var max_health_increase: int
var max_mana_increase: int
var attack_increase: int
var defense_increase: int
var speed_increase: int
var magic_increase: int
var accuracy_increase: int

var random_bonus: int
var level_up_count: int
var next_characters: Array[CombatantData]
var current_character: CombatantData

func get_xp_requirement(level: int) -> int:
	return 5 * 2 ** level

func start_level_up(characters: Array[CombatantData]) -> void:
	next_characters = characters
	_level_up_next_character()

func _level_up_next_character() -> void:
	if next_characters.size() > 0:
		current_character = next_characters.pop_back()
		_increase_level()
		_set_stat_increase()
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.setup_ui()
	else:
		done_leveling_up.emit()

func _increase_level() -> void:
	level_up_count = 0
	var xp_requirement: int = get_xp_requirement(current_character.level)
	while current_character.xp >= xp_requirement:
		level_up_count += 1
		current_character.level += 1
		current_character.xp -= xp_requirement
		xp_requirement = get_xp_requirement(current_character.level)

func _set_stat_increase() -> void:
	max_health_increase = current_character.max_health_increase_by_level * level_up_count
	max_mana_increase = current_character.max_mana_increase_by_level * level_up_count
	attack_increase = current_character.base_attack_increase_by_level * level_up_count
	defense_increase = current_character.base_defense_increase_by_level * level_up_count
	speed_increase = current_character.base_speed_increase_by_level * level_up_count
	magic_increase = current_character.base_magic_increase_by_level * level_up_count
	accuracy_increase = current_character.base_accuracy_increase_by_level * level_up_count

func _increase_stats() -> void:
	current_character.max_health += max_health_increase
	current_character.max_mana += max_mana_increase
	current_character.base_attack += max_health_increase
	current_character.base_defense += defense_increase
	current_character.base_speed += speed_increase
	current_character.base_magic_increase_by_level += magic_increase
	current_character.base_accuracy += accuracy_increase
	current_character.health = current_character.max_health
	current_character.mana = current_character.max_mana

func _on_max_health_pressed() -> void:
	max_health_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.MAX_HEALTH)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_max_mana_pressed() -> void:
	max_mana_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.MAX_MANA)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_attack_pressed() -> void:
	attack_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.ATTACK)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_defense_pressed() -> void:
	defense_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.DEFENSE)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_speed_pressed() -> void:
	speed_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.SPEED)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_magic_pressed() -> void:
	magic_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.MAGIC)
	else:
		_increase_stats()
		_level_up_next_character()

func _on_accuracy_pressed() -> void:
	accuracy_increase += random_bonus
	level_up_count -= 1
	if level_up_count > 0:
		random_bonus = randi_range(min_bonus, max_bouns)
		level_up_ui.reset_ui(Stat.ACCURACY)
	else:
		_increase_stats()
		_level_up_next_character()
