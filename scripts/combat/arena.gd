class_name Arena
extends Node2D

signal battle_ended

@onready var attack_button: Button = $UI/PanelContainer/VBoxContainer/AttackButton
@onready var flee_button: Button = $UI/PanelContainer/VBoxContainer/FleeButton
@onready var party_slots: Array[Marker2D] = [$Party/Slot1, $Party/Slot2, $Party/Slot3]
@onready var enemy_slots: Array[Marker2D] = [$Enemies/Slot1, $Enemies/Slot2, $Enemies/Slot3]

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var all_combatants: Array[Combatant] = []

func setup_battle() -> void:
	spawn_party()
	spawn_enemies()
	all_combatants = party + enemies
	
	flee_button.pressed.connect(_on_flee_pressed, CONNECT_ONE_SHOT)
	
# TODO: Use the same function to spawn party or enemies
func spawn_party() -> void:
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	for i in PartyManager.party.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup_from_data(PartyManager.party[i])
		combatant.position = party_slots[i].position
		$Party.add_child(combatant)
		party.append(combatant)
		
func spawn_enemies() -> void:
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	# Spawn the 3 enemies
	for i in range(3):
		var combatant: Combatant = combatant_scene.instantiate()
		var enemy_data := preload("res://resources/combatants/enemy.tres")
		
		combatant.setup_from_data(enemy_data)
		combatant.position = enemy_slots[i].position
		$Enemies.add_child(combatant)
		enemies.append(combatant)
		
func cleanup_battle() -> void:
	for combatant in all_combatants:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
func _on_flee_pressed() -> void:
	battle_ended.emit()

#signal battle_ended
#
#var party: Array[Combatant] = []
#var enemies: Array[Combatant] = []
#var all_combatants: Array[Combatant] = []
#
#var current_turn_index := 0
#var awaiting_user_input := true
#
#func setup_battle() -> void:
#	spawn_party()
#	spawn_enemies()
#	
#	all_combatants = party + enemies
#		
#	$UI/PanelContainer/VBoxContainer/AttackButton.pressed.connect(_on_attack_pressed)
#	$UI/PanelContainer/VBoxContainer/FleeButton.pressed.connect(_on_flee_pressed)
#	
#	next_turn()
#	
#func next_turn() -> void:
#	party = party.filter(func(c: Combatant): return  c.health > 0)
#	enemies = enemies.filter(func(c: Combatant): return c.health > 0)
#	all_combatants = party + enemies
#	
#	if party.size() == 0:
#		$UI/BattleResultLabel.text = "Enemies win!"
#		await get_tree().create_timer(3.0).timeout
#		battle_ended.emit()
#		return
#		
#	if enemies.size() == 0:
#		$UI/BattleResultLabel.text = "Party wins!"
#		await get_tree().create_timer(3.0).timeout
#		battle_ended.emit()
#		return
#	
#	if current_turn_index >= all_combatants.size():
#		current_turn_index = 0
#		
#	var attacker := all_combatants[current_turn_index]
#	
#	if party.has(attacker):		
#		awaiting_user_input = true
#	else:
#		var target: Combatant = party.pick_random()
#		
#		target.take_damage(attacker.attack)
#		
#		current_turn_index += 1
#		
#		await get_tree().create_timer(2.0).timeout
#		
#		next_turn()
#			
#func spawn_party() -> void:
#	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
#	var player_data: CombatantData = preload("res://resources/combatants/player.tres")
#	var party_member_data: CombatantData = preload("res://resources/combatants/party_member.tres")
#	
#	# Spawn player first
#	var player_combatant: Combatant = combatant_scene.instantiate()
#	
#	player_combatant.setup_from_data(player_data)
#	player_combatant.position = $Party/Slot1.position
#	$Party.add_child(player_combatant)
#	party.append(player_combatant)
#		
#	for i in range(2):
#		var combatant: Combatant = combatant_scene.instantiate()
#		
#		combatant.setup_from_data(party_member_data)
#		combatant.position = $Party.get_node("Slot" + str(i + 2)).position
#		$Party.add_child(combatant)
#		party.append(combatant)
#		
#		
#func spawn_enemies() -> void:
#		var combatant_scene := preload("res://scenes/combat/combatant.tscn")
#		var combatant_data: CombatantData = preload("res://resources/combatants/enemy.tres")
#		
#		# Enemies size = 3
#		for i in range(3):
#			var combatant: Combatant = combatant_scene.instantiate()
#			
#			combatant.setup_from_data(combatant_data)
#			combatant.position = $Enemies.get_node("Slot" + str(i + 1)).position
#			$Enemies.add_child(combatant)
#			enemies.append(combatant)
#			
#func cleanup_battle() -> void:
#	for combatant in party + enemies:
#		if is_instance_valid(combatant):
#			combatant.queue_free()
#						
#	party.clear()
#	enemies.clear()
#	
#func _on_attack_pressed() -> void:
#	if not awaiting_user_input:
#		return
#		
#	var target: Combatant = enemies.pick_random()
#	var attacker := all_combatants[current_turn_index]
#		
#	target.take_damage(attacker.attack)
#	
#	awaiting_user_input = false
#	
#	current_turn_index += 1
#	
#	await get_tree().create_timer(2.0).timeout
#	
#	next_turn()
#
#func _on_flee_pressed() -> void:
#		battle_ended.emit()
#		$UI/PanelContainer/VBoxContainer/FleeButton.pressed.disconnect(_on_flee_pressed)
