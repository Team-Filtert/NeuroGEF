class_name BasicComboAttack
extends CombatantComboAction

func animate():
	var original_pos = source.position
	var target_pos = target.position

	var tween = source.create_tween()
	tween.tween_property(source, "position", target_pos, 0.3)
	await tween.finished

	await _handle_attack_action()

	tween = source.create_tween()
	tween.tween_property(source, "position", original_pos, 0.3)
	await tween.finished

@export var attack_multiplier: float = 1

func _handle_attack_action():
	action_result()

func get_value() -> int:
	return int(self.source.get_attack() * attack_multiplier)

func action_result() -> void:
	if mana_cost != 0:
		source.loose_mana(mana_cost)
	var base_damage := get_value()
	var blocked_damage := target.take_damage(base_damage)
	reward_ult_charge(base_damage, blocked_damage)
