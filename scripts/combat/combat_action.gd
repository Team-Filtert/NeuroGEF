class_name CombatAction
extends RefCounted

enum Type {
	ATTACK
}

var type: Type
var source: Combatant
var target: Combatant