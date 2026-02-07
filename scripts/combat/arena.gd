class_name Arena
extends Node2D

signal battle_ended

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var all_combatants: Array[Combatant] = []

var current_turn_index := 0
var awaiting_user_input := true

func setup_battle() -> void:
	spawn_party()
	spawn_enemies()
	
	all_combatants = party + enemies
		
	$UI/PanelContainer/VBoxContainer/AttackButton.pressed.connect(_on_attack_pressed)
	$UI/PanelContainer/VBoxContainer/FleeButton.pressed.connect(_on_flee_pressed)
	
	next_turn()
	
func next_turn() -> void:
	party = party.filter(func(c: Combatant): return c.health > 0)
	enemies = enemies.filter(func(c: Combatant): return c.health > 0)
	all_combatants = party + enemies
	
	if party.size() == 0:
		$UI/BattleResultLabel.text = "Enemies win!"
		await get_tree().create_timer(3.0).timeout
		battle_ended.emit()
		return
		
	if enemies.size() == 0:
		$UI/BattleResultLabel.text = "Party wins!"
		await get_tree().create_timer(3.0).timeout
		battle_ended.emit()
		return
	
	if current_turn_index >= all_combatants.size():
		current_turn_index = 0
		
	var attacker := all_combatants[current_turn_index]
	attacker.show_attacker_highlight()
	
	if party.has(attacker):		
		awaiting_user_input = true
	else:
		var target: Combatant = party.pick_random()
		
		target.show_target_highlight()
		target.take_damage(50.0)
		
		current_turn_index += 1
		
		await get_tree().create_timer(2.0).timeout
		
		attacker.hide_attacker_highlight()
		target.hide_target_highlight()
		
		next_turn()
			
func spawn_party() -> void:
	var spawned: Array[Combatant] = []
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
		
	# Party size = 3
	for i in range(3):
		var combatant: Combatant = combatant_scene.instantiate()
				
		if i == 0:
			combatant.combatant_name = "Player"
			combatant.position = $Party/PrimarySlot.position
		else:
			combatant.combatant_name = "Party Member"
			combatant.position = $Party.get_node("SecondarySlot" + str(i)).position
						
		$Party.add_child(combatant)
		spawned.append(combatant)
				
		party = spawned
		
func spawn_enemies() -> void:
		var spawned: Array[Combatant] = []
		var combatant_scene := preload("res://scenes/combat/combatant.tscn")
		
		# Enemies size = 3
		for i in range(3):
			var combatant: Combatant = combatant_scene.instantiate()
			
			if i == 0:
				combatant.combatant_name = "Strong Enemy"
				combatant.position = $Enemies/PrimarySlot.position
			else:
				combatant.combatant_name = "Weaker Enemy"
				combatant.position = $Enemies.get_node("SecondarySlot" + str(i)).position
						
			$Enemies.add_child(combatant)
			spawned.append(combatant)
				
		enemies = spawned
		
func cleanup_battle() -> void:
	for combatant in party + enemies:
		if is_instance_valid(combatant):
			combatant.queue_free()
						
	party.clear()
	enemies.clear()
	
func _on_attack_pressed() -> void:
	if not awaiting_user_input:
		return
		
	var attacker := all_combatants[current_turn_index]
	var target: Combatant = enemies.pick_random()
	
	target.show_target_highlight()
	target.take_damage(50.0)
	
	awaiting_user_input = false
	
	current_turn_index += 1
	
	await get_tree().create_timer(2.0).timeout
	
	attacker.hide_attacker_highlight()
	target.hide_target_highlight()
	
	next_turn()

func _on_flee_pressed() -> void:
		battle_ended.emit()
		$UI/PanelContainer/VBoxContainer/FleeButton.pressed.disconnect(_on_flee_pressed)
