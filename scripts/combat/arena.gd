class_name Arena
extends Node2D

signal battle_ended

@export var menu: VBoxMenu

@onready var party_slots: Array[Marker2D] = [$Party/Slot1, $Party/Slot2, $Party/Slot3]
@onready var enemy_slots: Array[Marker2D] = [$Enemies/Slot1, $Enemies/Slot2, $Enemies/Slot3]
@onready var attack_button: Button = $UI/PanelContainer/VBoxContainer/AttackButton
@onready var block_button: Button = $UI/PanelContainer/VBoxContainer/BlockButton
@onready var flee_button: Button = $UI/PanelContainer/VBoxContainer/FleeButton
@onready var target_indicator: SelectTargetIndicator = $SelectTargetIndicator

var awaiting_player_input := true

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var action_queue: Array[CombatantAction] = []
var player_actions_submited := 0

func setup_battle(enemy_data: Array[CombatantData]) -> void:
	party = spawn_combatants(PartyManager.party, party_slots, $Party)
	enemies = spawn_combatants(enemy_data, enemy_slots, $Enemies)

	player_actions_submited = 0
	get_current_combatant().set_selected(true)
	
	attack_button.pressed.connect(_on_attack_pressed)
	block_button.pressed.connect(_on_block_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	
func cleanup_battle() -> void:
	attack_button.pressed.disconnect(_on_attack_pressed)
	flee_button.pressed.disconnect(_on_flee_pressed)
	
	for combatant in party + enemies:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
	party.clear()
	enemies.clear()
	action_queue.clear()
	
func spawn_combatants(combatant_data: Array[CombatantData], slots: Array[Marker2D], parent: Node2D) -> Array[Combatant]:
	var spawned: Array[Combatant] = []
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	for i in combatant_data.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup(combatant_data[i])
		combatant.position = slots[i].position
		spawned.append(combatant)
		parent.add_child(combatant)
	
	return spawned

func get_current_combatant() -> Combatant:
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	if not alive_party:
		printerr("No alive combatants in party")
		return null
	if player_actions_submited >= alive_party.size():
		printerr("player_actions_submited is greater than alive_party size. This should not happen.")
		return null

	return alive_party[player_actions_submited]
	
func _queue_enemy_actions() -> void:
	awaiting_player_input = false
	attack_button.disabled = true
	
	# Filter out dead combatants
	var alive_enemies := get_alive_enemies()
	var alive_party := get_alive_party()
	
	for enemy in alive_enemies:
		var action := CombatantAction.new()
		
		action.type = CombatantAction.Type.ATTACK
		action.source = enemy
		action.target = alive_party.pick_random()
		action_queue.append(action)
	
	_resolve_actions()
	
func _resolve_actions() -> void:
	action_queue.sort_custom(func(a, b):
		# Block hase more priority than attack
		if a.type == CombatantAction.Type.BLOCK:
			return true

		if a.source.get_speed() == b.source.get_speed():
			return true
		return a.source.get_speed() > b.source.get_speed()
	)

	var delayed_actions: Array[Callable] = []

	for i in action_queue.size():
		var action := action_queue[i]
		
		# Ignore actions with dead sources
		if not action.source.is_alive():
			continue
		
		# Lunge attack effect
		match action.type:
			CombatantAction.Type.ATTACK:
				# Ignore action if no target or target is dead
				if not action.target or not action.target.is_alive():
					continue

				var original_pos := action.source.position
				var target_pos := action.target.position

				delayed_actions.append(func():
					var tween := create_tween()
					tween.tween_property(action.source, "position", target_pos, 0.3)
					tween.tween_property(action.source, "position", original_pos, 0.3)
					await tween.finished
							
					action.target.take_damage(action.source.get_attack())
					await get_tree().create_timer(0.5).timeout
				)
			CombatantAction.Type.BLOCK:
				action.source.set_blocking(true)
	
	for delayed_action in delayed_actions:
		await delayed_action.call()
		
		if _has_battle_ended():
			return
	
	_end_turn()

func _has_battle_ended() -> bool:
	var alive_enemies := get_alive_enemies()
	var alive_party := get_alive_party()
	
	if alive_enemies.size() == 0:
		battle_ended.emit()
		return true
	
	if alive_party.size() == 0:
		battle_ended.emit()
		return true
	
	return false
	
func _end_turn() -> void:
	action_queue.clear()
	player_actions_submited = 0
	awaiting_player_input = true
	attack_button.disabled = false

	# Reset statuses such as block
	get_all_alive_combatants().map(func(c: Combatant): c.reset_status())

	get_current_combatant().set_selected(true)
	menu.configure_focus()

func _on_attack_pressed() -> void:
	if not awaiting_player_input:
		return
		
	# Filter out dead combatants
	var alive_party: Array[Combatant] = get_alive_party()
	var alive_enemies: Array[Combatant] = get_alive_enemies()
	
	if player_actions_submited >= alive_party.size():
		return

	var selected_combatant := get_current_combatant()
	
	var action := CombatantAction.new()
	
	action.type = CombatantAction.Type.ATTACK
	action.source = selected_combatant

	var picked_target = await target_indicator.wait_for_target_selection(alive_enemies)

	if not picked_target:
		# action canceled
		menu.configure_focus()
		get_current_combatant().set_selected(true)
		return

	action.target = picked_target
	action_queue.append(action)
	
	player_actions_submited += 1
	selected_combatant.set_selected(false)
	
	if player_actions_submited >= alive_party.size():
		_queue_enemy_actions()
	else:
		menu.configure_focus()
		get_current_combatant().set_selected(true)

func _on_block_pressed() -> void:
	if not awaiting_player_input:
		return
	
	var selected_combatant := get_current_combatant()
	
	var action := CombatantAction.new()
	
	action.type = CombatantAction.Type.BLOCK
	action.source = selected_combatant

	action_queue.append(action)
	
	player_actions_submited += 1
	selected_combatant.set_selected(false)
	
	if player_actions_submited >= get_alive_party().size():
		_queue_enemy_actions()
	else:
		menu.configure_focus()
		get_current_combatant().set_selected(true)
	
func _on_flee_pressed() -> void:
	battle_ended.emit()

func get_alive_party() -> Array[Combatant]:
	return party.filter(func(c: Combatant): return c.is_alive())

func get_alive_enemies() -> Array[Combatant]:
	return enemies.filter(func(c: Combatant): return c.is_alive())

func get_all_alive_combatants() -> Array[Combatant]:
	return get_alive_party() + get_alive_enemies()
