class_name CombatantAction
extends RefCounted

enum Type {
	ATTACK
}

var type: Type
var source: Combatant
var target: Combatant