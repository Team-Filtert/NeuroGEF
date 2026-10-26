class_name Heal
extends ActionBase

## Restores HP to a party member. Scales off magic by default.

func _init() -> void:
	type = Type.HEAL
	target_side = TargetSide.ALLY
	damage_type = DamageType.MAGIC
