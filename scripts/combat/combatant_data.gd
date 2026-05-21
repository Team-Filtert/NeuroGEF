class_name CombatantData
extends Resource

@export var display_name: String
@export var texture: Texture2D

@export var max_health: int
var health: int
@export var max_mana: int
var mana: int
@export var base_attack: int
@export var base_defense: int
@export var base_speed: int

@export var max_health_increase_by_level: int = 1
@export var max_mana_increase_by_level: int = 1
@export var base_attack_increase_by_level: int = 1
@export var base_defense_increase_by_level: int = 1
@export var base_speed_increase_by_level: int = 1

@export var level: int = 1
@export var xp: int

@export var attack_actions: Array[CombatantAction]
@export var weapon: ItemWepon
@export var armors: Array[ItemArmor]
@export var artifacts: Array[ItemArtifact]

var max_health_for_level: int
var max_mana_for_level: int
var base_attack_for_level: int
var base_defense_for_level: int
var base_speed_for_level: int

var is_initialized := false
func initialize() -> void:
	if not is_initialized:
		health = max_health
		mana = max_mana
		is_initialized = true

func set_stats_for_level() -> void:
	max_health_for_level = max_health + max_health_increase_by_level * level
	max_mana_for_level = max_mana + max_mana_increase_by_level * level
	base_attack_for_level = base_attack + base_attack_increase_by_level * level
	base_speed_for_level = base_defense + base_defense_increase_by_level * level
	base_speed_for_level = base_speed + base_speed_increase_by_level * level
