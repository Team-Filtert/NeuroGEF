class_name ActionResolveState extends ArenaStateBase

@export var next_state: ArenaStateBase

# for DEBUG only
@export var block_minigame_scene: PackedScene

func enter() -> void:
	parent.awaiting_player_input = false
	_resolve_actions()

func exit() -> void:
	pass

func _resolve_actions() -> void:
	parent.ui_manager.hide_all_submenus()
	
	parent.action_queue.sort_custom(func(a, b):
		if a.type == CombatantActionStorage.Type.BLOCK:
			return true
		if a.source.get_speed() == b.source.get_speed():
			return true
		return a.source.get_speed() > b.source.get_speed()
	)
	
	var delayed_actions: Array[Callable] = []
	
	for action in parent.action_queue:
		if not action.source.is_alive():
			continue
		
		match action.type:
			CombatantActionStorage.Type.ATTACK:
				if not action.target or not action.target.is_alive():
					continue
				delayed_actions.append(_create_attack_action.bind(action))
			CombatantActionStorage.Type.BLOCK:
				action.source.set_blocking(true)
	
	for delayed in delayed_actions:
		await delayed.call()
		if parent._has_battle_ended():
			return
	
	if not parent._has_battle_ended():
		parent.change_state(next_state)

func _create_attack_action(action: CombatantAction) -> void:
	var original_pos = action.source.position
	var target_pos = action.target.position
	
	var tween = parent.create_tween()
	tween.tween_property(action.source, "position", target_pos, 0.3)
	await tween.finished
	
	if action.target.is_player_controlled:
		var block_minigame = block_minigame_scene.instantiate() as MiniGameBase
		parent.add_child(block_minigame)
		block_minigame.position = Vector2(200, 0)
		block_minigame.do_minigame()
		var args = await block_minigame.minigame_completed
		var success = args[0]
		var block_multiplier = args[1]
		if success:
			action.target.set_blocking(true)
			action.target.take_damage(action.source.get_attack() - block_multiplier)
			action.target.set_blocking(false)
		else:
			action.target.take_damage(action.source.get_attack())
		block_minigame.queue_free()
	else:
		action.target.take_damage(action.source.get_attack())
	
	tween = parent.create_tween()
	tween.tween_property(action.source, "position", original_pos, 0.3)
	await tween.finished
	await parent.get_tree().create_timer(0.5).timeout
