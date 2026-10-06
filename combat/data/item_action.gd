class_name ItemAction
extends ActionBase

## The combat action attached to a consumable. [member item_id] is what the
## inventory removes once the action is submitted; [member heal] / [member mana]
## are its effect, and the inherited [member ActionBase.status] can add one too.

@export var item_id: StringName = &""
@export var heal: int = 0
@export var mana: int = 0


func _init() -> void:
	target_side = TargetSide.ALLY
	uses_timing = false
	power = 0.0


func execute(_actor: Combatant, victim: Combatant, _grade: int) -> int:
	var total := 0
	if heal > 0:
		total += victim.receive_heal(heal)
	if mana > 0:
		victim.receive_mana(mana)
	if status != null:
		victim.add_status(status.duplicate(true))
	return total
