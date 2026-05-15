class_name CombatantUltAction
extends CombatantAction

@export var ult_charge_cost: int = 250

func is_accessible_ult(area: Arena) -> bool:
	# check if ult gauge is full
	return area.max_party_ult_charge == area.party_ult_charge

func use_ult_charge(amount: int) -> void:
	change_ult_charge.call(-amount, not source.is_player_controlled)
