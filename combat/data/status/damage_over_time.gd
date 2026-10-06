class_name DamageOverTime
extends StatusEffect

## Burn / poison: deals [member damage] to the afflicted each time it ticks.
## Ignores defense (it is not an attack).

@export var damage: int = 3


func tick(target: Combatant) -> void:
	target.take_damage(damage, true)
