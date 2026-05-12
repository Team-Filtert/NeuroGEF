class_name Arena
extends Node2D

@export var combo_actions: Array[CombatantComboAction]
@export var max_party_ult_charge: int
@export var max_boss_ult_charge: int

var party_ult_charge: int = 0:
	set(value):
		party_ult_charge = clampi(value, 0, max_party_ult_charge)
var boss_ult_charge: int = 0:
	set(value):
		boss_ult_charge = clampi(value, 0, max_boss_ult_charge)
