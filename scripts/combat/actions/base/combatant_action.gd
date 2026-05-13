class_name CombatantAction
extends Resource

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
var arena: Arena

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

func reward_ult_charge(base_damage: int, blocked_damage: int) -> void:
	var damage_charge := base_damage - blocked_damage
	var block_charge := blocked_damage if target.is_blocking else 0
	
	if source.is_player_controlled:
		arena.party_ult_charge += damage_charge
		arena.boss_ult_charge += block_charge
	else:
		arena.party_ult_charge += block_charge
		arena.boss_ult_charge += damage_charge
