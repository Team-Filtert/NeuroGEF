class_name Combo
extends Attack

## A combined attack that is only offered while every named combatant is in the
## party. The arena checks [member required_characters_names] against the party.

@export var required_characters_names: Array[StringName] = []
