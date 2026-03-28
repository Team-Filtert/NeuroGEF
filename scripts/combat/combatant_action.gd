class_name CombatantAction
extends RefCounted



var display_name: String
var type: CombatantActionStorage.Type
var source: Combatant
var target: Combatant

var process_func: Callable
