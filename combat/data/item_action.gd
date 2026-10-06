class_name ItemAction
extends ActionBase

## The combat action attached to a consumable. [member item_id] is what the
## inventory removes once the action is submitted, so items stay data-driven.

@export var item_id: StringName = &""

func _init() -> void:
	target_side = TargetSide.ALLY
