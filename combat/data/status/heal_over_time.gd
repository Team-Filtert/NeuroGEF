class_name HealOverTime
extends StatusEffect

## Regeneration: restores [member heal] to the afflicted each time it ticks.

@export var heal: int = 3


func tick(target: Combatant) -> void:
	target.receive_heal(heal)
