class_name BasicItemAttack
extends CombatantItemAction

static func create_action(new_name: String, new_source: Combatant) -> BasicItemAttack:
	var action = BasicItemAttack.new()
	action.display_name = new_name
	action.type = CombatantActionStorage.Type.ATTACK
	action.source = new_source
	return action

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

func get_value() -> int:
	return int(self.source.get_attack() * attack_multiplier)

func action_result() -> void:
	target.take_damage(get_value())
