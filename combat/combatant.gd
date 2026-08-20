class_name Combatant
extends Node2D

@onready var sprite2d: Sprite2D

var resting_position: Vector2

func setup(data: CombatantData, res_pos: Vector2) -> void:
	resting_position = res_pos
	sprite2d.texture = data.texture
