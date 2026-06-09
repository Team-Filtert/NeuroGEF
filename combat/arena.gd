class_name Arena
extends Node2D

@export var combo_actions: Array[CombatantComboAction]
@export var max_party_ult_charge: int
@export var max_boss_ult_charge: int

@onready  var ui_manager: ArenaUIManagerComponent = $ArenaComponent/ArenaUIManagerComponent

var party_ult_charge: int = 0:
	set(value):
		party_ult_charge = clampi(value, 0, max_party_ult_charge)
var boss_ult_charge: int = 0:
	set(value):
		boss_ult_charge = clampi(value, 0, max_boss_ult_charge)

func change_ult_charge(change: int, is_boss: bool):
	if is_boss:
		boss_ult_charge += change
		ui_manager.update_ult_display(true)
	else:
		party_ult_charge += change
		ui_manager.update_ult_display(false)

func reset_ult_charges():
	party_ult_charge = 0
	boss_ult_charge = 0
