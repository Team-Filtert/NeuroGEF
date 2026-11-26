class_name ComboStep
extends Resource

## One timed hit of a [Combo]. The arena finds the named participant, runs a
## timing challenge for them, and applies this step's share of the combo damage.

@export var actor_name: StringName = &""
## Multiplier over the combo's base power for this hit.
@export var power: float = 1.0
## Prompt shown in the info panel while this step's challenge runs.
@export var input_hint: String = "SPACE"
