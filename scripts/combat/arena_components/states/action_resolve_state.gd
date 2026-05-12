class_name ActionResolveState
extends ArenaStateBase

@export var next_state: ArenaStateBase
@export var ui_manager: ArenaUIManagerComponent

func enter() -> void:
	_resolve_actions()

func exit() -> void:
	pass

func _resolve_actions() -> void:
	parent.action_queue.sort_custom(func(a, b):
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
	if not action.source.is_alive():
		# this guy is dead, don't need to resolve
		return
	
	var is_player = action.source.is_player_controlled
	
	if not action.target.is_alive():
		# this guy beating a dead foe
		# either stop them or redirect hit
		action.target = parent.get_alive_enemies().pick_random() \
			if is_player else parent.get_alive_party().pick_random()
	
	if not action.party_ult_charge_changed.is_connected(_on_party_ult_charge_changed):
		action.party_ult_charge_changed.connect(_on_party_ult_charge_changed)
	if not action.boss_ult_charge_changed.is_connected(_on_boss_ult_charge_changed):
		action.boss_ult_charge_changed.connect(_on_boss_ult_charge_changed)
	
	await action.animate()
	
	await parent.get_tree().create_timer(0.5).timeout

func _on_party_ult_charge_changed(change: int):
	arena.party_ult_charge += change
	ui_manager.update_party_ult_display()

func _on_boss_ult_charge_changed(change: int):
	arena.boss_ult_charge += change
	ui_manager.update_boss_ult_display()
