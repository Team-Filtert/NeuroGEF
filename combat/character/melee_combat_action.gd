extends CombatAction
class_name MeleeCombatAction

func execute_action(cur_char: Character, target: Character):
	var initial_pos = cur_char.global_position
	var move_anim_tween = cur_char.create_tween()
	move_anim_tween.set_trans(Tween.TRANS_SPRING)
	move_anim_tween.set_ease(Tween.EASE_IN_OUT)
	move_anim_tween.tween_property(cur_char, "global_position", target.get_target_pos(), 1)
	await move_anim_tween.finished

	target.get_damage(cur_char.stats.get_attack())

	var damage_anim_tween = target.create_tween()
	damage_anim_tween.set_trans(Tween.TRANS_QUINT)
	damage_anim_tween.set_ease(Tween.EASE_OUT_IN)
	damage_anim_tween.tween_property(target, "modulate:v", 5, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 1, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 5, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 1, 0.2)

	move_anim_tween = cur_char.create_tween()
	move_anim_tween.set_trans(Tween.TRANS_SPRING)
	move_anim_tween.set_ease(Tween.EASE_IN_OUT)
	move_anim_tween.tween_property(cur_char, "global_position", initial_pos, 1)
	await move_anim_tween.finished

func is_valid_target(cur_char: Character, target: Character) -> bool:
	if cur_char.is_player:
		return cur_char != target and not target.is_player and target.stats.get_health() > 0
	else:
		return cur_char != target and target.is_player and target.stats.get_health() > 0