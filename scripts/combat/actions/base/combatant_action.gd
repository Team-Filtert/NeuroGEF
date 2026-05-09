class_name CombatantAction
extends Resource

signal player_ult_charge_changed(change: int)

static func create_action(new_name: String, new_source: Combatant) -> CombatantAction:
	var action = CombatantAction.new()
	action.display_name = new_name
	action.source = new_source
	return action

@export var display_name: String
@export var type: CombatantActionStorage.Type
@export var mana_cost: int = 0
var source: Combatant
var target: Combatant

func is_accessible(current_combatant: Combatant) -> bool:
	return current_combatant.mana - mana_cost >= 0

func animate():
	pass

# for processing action in UI
var process_func: Callable

## This value will be used for various
## purposes, most simple and straightforward
## example is damage calculated for an attack
func get_value() -> int:
	return 0

## Called on action execution, i. e.
## when player pressed corresponding
## button
func action_result() -> void:
	pass

func change_ult_charge(change: int) -> void:
	player_ult_charge_changed.emit(change)
