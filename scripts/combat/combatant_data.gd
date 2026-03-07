class_name CombatantData
extends Resource

@export var display_name: String
@export var texture: Texture2D

@export var max_health: int
var health: int
@export var base_attack: int
@export var base_speed: int

var is_initialized := false
func initialize() -> void:
    if not is_initialized:
        health = max_health
        is_initialized = true
