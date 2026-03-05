class_name Arena
extends Node2D

signal battle_ended

@onready var party_slots: Array[Marker2D] = [$Party/Slot1, $Party/Slot2, $Party/Slot3]
@onready var enemy_slots: Array[Marker2D] = [$Enemies/Slot1, $Enemies/Slot2, $Enemies/Slot3]
@onready var attack_button: Button = $UI/PanelContainer/VBoxContainer/AttackButton
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
	
	attack_button.pressed.connect(_on_attack_pressed)
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
	
func _queue_enemy_actions() -> void:
	awaiting_player_input = false
	attack_button.disabled = true
	
	# Filter out dead combatants
	var alive_enemies := enemies.filter(func(c: Combatant): return c.is_alive())
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	
	for enemy in alive_enemies:
		var action := CombatantAction.new()
		
		action.type = CombatantAction.Type.ATTACK
		action.source = enemy
		action.target = alive_party.pick_random()
		action_queue.append(action)
	
	_resolve_actions()
	
func _resolve_actions() -> void:
	for i in action_queue.size():
		var action := action_queue[i]
		
		# Ignore actions with dead sources or targets
		if not action.source.is_alive() or not action.target.is_alive():
			continue
		
		# Lunge attack effect
		match action.type:
			CombatantAction.Type.ATTACK:
				var original_pos := action.source.position
				var target_pos := action.target.position
				
				var tween := create_tween()
				tween.tween_property(action.source, "position", target_pos, 0.3)
				tween.tween_property(action.source, "position", original_pos, 0.3)
						
				await tween.finished
						
				action.target.take_damage(action.source.attack)
				await get_tree().create_timer(0.5).timeout
		
		if _has_battle_ended():
			return
	
	_end_turn()

func _has_battle_ended() -> bool:
	var alive_enemies := enemies.filter(func(c: Combatant): return c.is_alive())
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	
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

func _on_attack_pressed() -> void:
	if not awaiting_player_input:
		return
		
	# Filter out dead combatants	
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	var alive_enemies := enemies.filter(func(c: Combatant): return c.is_alive())
	
	if player_actions_submited >= alive_party.size():
		return
	
	var action := CombatantAction.new()
	
	action.type = CombatantAction.Type.ATTACK
	action.source = alive_party[player_actions_submited]

	var picked_target = await target_indicator.wait_for_target_selection(alive_enemies)

	action.target = picked_target
	action_queue.append(action)
	
	player_actions_submited += 1
	
	if player_actions_submited >= alive_party.size():
		_queue_enemy_actions()
	
func _on_flee_pressed() -> void:
	battle_ended.emit()