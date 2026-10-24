class_name Attack
extends ActionBase

## A plain offensive action. Subclass it (see [Combo], [Ultimate]) or just author
## a resource and tune [member power] / [member damage_type].

func _init() -> void:
	type = Type.ATTACK
	target_side = TargetSide.ENEMY
