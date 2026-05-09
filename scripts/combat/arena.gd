class_name Arena
extends Node2D

@export var combo_actions: Array[CombatantComboAction]
@export var max_player_ult_charge: int
var player_ult_charge: int = 0:
	set(value):
		player_ult_charge = clampi(value, 0, max_player_ult_charge)
