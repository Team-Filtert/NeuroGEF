class_name StatusEffect
extends Resource

## A lingering effect on a combatant (burn, poison, paralysis, ...).
##
## When it fires is data-driven, matching the design notes: most effects fire at
## the end of the afflicted's turn, some at the start of it, and some after the
## whole round. Effects that share a [member priority] are treated as resolving
## together, so keep same-priority effects order-independent.

enum Timing { START_OF_TURN, END_OF_TURN, END_OF_ROUND }

@export var display_name: StringName = &"Status"
@export var timing: Timing = Timing.END_OF_TURN
## Lower runs first. Equal priority should resolve independently of order.
@export var priority: int = 0
## Rounds remaining; a value <= 0 never expires on its own.
@export var duration: int = 3


## Called each time the effect fires, from the arena's turn phases.
func tick(_target: Combatant) -> void:
	pass
