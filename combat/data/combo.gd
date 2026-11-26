class_name Combo
extends Attack

## A combined attack. Each step names a participant and drives one timing
## challenge; only the initiator's turn is spent, so the partner can still act
## that round. With no steps it falls back to a normal party-gated attack.

@export var required_characters_names: Array[StringName] = []
@export var steps: Array[ComboStep] = []


## Every character that must be alive and un-acted for the combo to be offered.
## Step actors are included automatically.
func get_required_names() -> Array[StringName]:
	var names: Array[StringName] = required_characters_names.duplicate()
	for step in steps:
		if step != null and not step.actor_name.is_empty() and not names.has(step.actor_name):
			names.append(step.actor_name)
	return names
