class_name CombatantAction
extends RefCounted

enum Type {
	ATTACK,
	BLOCK,
}

var display_name: String
var type: Type
var source: Combatant
var target: Combatant

var process_func: Callable
