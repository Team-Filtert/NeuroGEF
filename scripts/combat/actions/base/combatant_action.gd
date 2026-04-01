class_name CombatantAction
extends Resource

static func create_action(new_name: String, new_source: Combatant) -> CombatantAction:
	var action = CombatantAction.new()
	action.display_name = new_name
	action.source = new_source
	return action

@export var display_name: String
@export var type: CombatantActionStorage.Type
var source: Combatant
var target: Combatant

func animate():
	pass

# for processing action in UI
var process_func: Callable


func get_value():
	return 0

func action_result():
	pass
