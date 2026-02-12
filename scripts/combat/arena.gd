class_name Arena
extends Node2D

signal battle_ended

@onready var attack_button: Button = $UI/PanelContainer/VBoxContainer/AttackButton
@onready var flee_button: Button = $UI/PanelContainer/VBoxContainer/FleeButton
@onready var party_slots: Array[Marker2D] = [$SpawnPositions/Party/Slot1, $SpawnPositions/Party/Slot2, $SpawnPositions/Party/Slot3]
@onready var enemy_slots: Array[Marker2D] = [$SpawnPositions/Enemies/Slot1, $SpawnPositions/Enemies/Slot2, $SpawnPositions/Enemies/Slot3]

var action_queue: Array[CombatAction] = []
var awaiting_player_input := true
var selected_party_member_index := 0
var selected_target_index := 0

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var all_combatants: Array[Combatant] = []

func setup_battle(enemy_combatants: Array[CombatantData]) -> void:
	spawn_combatants(PartyManager.party, party_slots, $Party, party)
	spawn_combatants(enemy_combatants, enemy_slots, $Enemies, enemies)
	all_combatants = party + enemies
	
	attack_button.pressed.connect(_on_attack_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	
func cleanup_battle() -> void:
	awaiting_player_input = true
	selected_party_member_index = 0
	selected_target_index = 0
	action_queue.clear()
	party.clear()
	enemies.clear()
	
	attack_button.pressed.disconnect(_on_attack_pressed)
	flee_button.pressed.disconnect(_on_flee_pressed)
	
	for combatant in all_combatants:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
func spawn_combatants(combatants: Array[CombatantData], slots: Array[Marker2D], parent: Node2D, output_array: Array[Combatant]) -> void:
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	for i in combatants.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup_from_data(combatants[i])
		combatant.position = slots[i].position
		parent.add_child(combatant)
		output_array.append(combatant)
		
func _start_player_input_phase() -> void:
	pass
		
func _on_attack_pressed() -> void:
	if not awaiting_player_input:
		return

	var action := CombatAction.new()
	
	action.type = CombatAction.Type.ATTACK
	action.source = party[selected_party_member_index]
	action.target = enemies[selected_target_index]
	action_queue.append(action)
	
func _on_flee_pressed() -> void:
	flee_button.pressed.disconnect(_on_flee_pressed)
	battle_ended.emit()
