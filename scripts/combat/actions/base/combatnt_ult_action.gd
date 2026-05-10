class_name CombatantUltAction
extends CombatantAction

@export var ult_charge_cost: int = 250

func is_accessible_ult(area: Arena) -> bool:
	# check if ult gauge is full
	return area.max_player_ult_charge == area.player_ult_charge
