class_name BasicAttackAction
extends CombatantAction

static func create_action(new_name: String, new_source: Combatant) -> BasicAttackAction:
	var action = BasicAttackAction.new()
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

@export var block_minigame_scene: PackedScene = preload("res://scenes/combat/minigames/block_minigame.tscn")

@export var attack_multiplier: float = 1.0

func _handle_attack_action():
	var is_player = target.is_player_controlled

	if is_player:
		var block_minigame = block_minigame_scene.instantiate() as MiniGameBase
		source.add_child(block_minigame)
		block_minigame.position = Vector2(200, 0)
		block_minigame.do_minigame(self)
		await block_minigame.minigame_completed
	else:
		action_result()

func get_value():
	return self.source.get_attack() * attack_multiplier

func action_result():
	if mana_cost != 0:
		source.loose_mana(mana_cost)
	var ult_charge_change := target.take_damage(get_value())
	change_ult_charge(ult_charge_change)
