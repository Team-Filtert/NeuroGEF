class_name Combatant
extends Node2D

@onready var sprite2d: Sprite2D

func setup(data: CombatantData) -> void:
	sprite2d.texture = data.texture
