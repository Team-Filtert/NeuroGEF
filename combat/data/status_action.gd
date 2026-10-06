class_name StatusAction
extends ActionBase

## Applies a [StatusEffect] with no damage or healing of its own (a debuff, a
## buff, a lingering burn). The effect itself comes from [member ActionBase.status];
## this class only supplies sensible defaults. For "damage + effect" use an
## [Attack] with a status set instead.

func _init() -> void:
	type = Type.BUFF
	target_side = TargetSide.ENEMY
	uses_timing = false
	power = 0.0
