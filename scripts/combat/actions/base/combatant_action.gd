class_name CombatantAction
extends RefCounted

static func create_action(new_name: String, new_source: Combatant) -> CombatantAction:
	var action = CombatantAction.new()
	action.display_name = new_name
	action.source = new_source
	return action

var display_name: String
var type: CombatantActionStorage.Type
var source: Combatant
var target: Combatant

func animate():
	pass

# for processing action in UI
var process_func: Callable
