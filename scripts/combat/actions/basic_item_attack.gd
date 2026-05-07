class_name BasicItemAttack
extends CombatantItemAction

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

@export var attack_multiplier: float = 1.0

func _handle_attack_action():
	action_result()

func get_value():
	return self.source.get_attack() * attack_multiplier

func action_result():
	target.take_damage(get_value())
