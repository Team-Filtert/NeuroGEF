extends CombatAction
class_name MagicCombatAction

@export var mana_cost: int = 15
@export var damage_amount: int = 30


func execute_action(_cur_char: Character, target: Character):
	target.get_damage(damage_amount)
	var damage_anim_tween = target.create_tween()
	damage_anim_tween.set_trans(Tween.TRANS_QUINT)
	damage_anim_tween.set_ease(Tween.EASE_OUT_IN)
	damage_anim_tween.tween_property(target, "modulate:v", 5, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 1, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 5, 0.2)
	damage_anim_tween.tween_property(target, "modulate:v", 1, 0.2)
	await damage_anim_tween.finished


func is_valid_target(cur_char: Character, target: Character) -> bool:
	if cur_char.is_player:
		return cur_char != target and not target.is_player and target.stats.get_health() > 0
	else:
		return cur_char != target and target.is_player and target.stats.get_health() > 0
