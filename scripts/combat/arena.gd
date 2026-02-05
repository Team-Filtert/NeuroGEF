extends Node2D

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var all_combatants: Array[Combatant] = []
var current_turn_index := 0
var awaiting_user_input := true

func _ready() -> void:
	setup_ui()
	spawn_combatants()
	start_combat()
	
func setup_ui() -> void:
	$UI/PanelContainer/VBoxContainer/FleeButton.pressed.connect(_on_flee_pressed)
	$UI/PanelContainer/VBoxContainer/ItemButton.pressed.connect(_on_item_pressed)
	$UI/PanelContainer/VBoxContainer/MagicButton.pressed.connect(_on_magic_pressed)
	$UI/PanelContainer/VBoxContainer/MeleeButton.pressed.connect(_on_melee_pressed)
	
func spawn_combatants() -> void:
	var combatant_scene = preload("res://scenes/combat/combatant.tscn")
	
	var hero: Combatant = combatant_scene.instantiate()
	
	hero.combatant_name = "Hero"
	hero.max_health = 100.0
	hero.health = 100.0
	hero.position = $Party/Slot.position
	$Party.add_child(hero)
	party.append(hero)
	
	var enemy: Combatant = combatant_scene.instantiate()
	
	enemy.combatant_name = "Enemy"
	enemy.max_health = 100.0
	enemy.health = 100.0
	enemy.position = $Enemies/Slot.position
	$Enemies.add_child(enemy)
	enemies.append(enemy)
	
func start_combat() -> void:
	all_combatants = party + enemies
	next_turn()
	
func next_turn() -> void:
	party = party.filter(func(c): return is_instance_valid(c) and c.health > 0)
	enemies = enemies.filter(func(c): return is_instance_valid(c) and c.health > 0)
	
	if enemies.size() == 0:
		print("Party wins!")
		return
	
	if party.size() == 0:
		print("Enemies win!")
		return
	
	if current_turn_index >= all_combatants.size():
		current_turn_index = 0
		
	var attacker := all_combatants[current_turn_index]
	
	if party.has(attacker):
		awaiting_user_input = true
	else:
		var target := party[0]
		target.take_damage(25.0)
		
		print("%s takes damage from %s!" % [target.combatant_name, attacker.combatant_name])
		
		current_turn_index += 1
		await get_tree().create_timer(1.0).timeout
		next_turn()
	
func _on_flee_pressed() -> void:
	print("flee_pressed")
	
func _on_item_pressed() -> void:
	print("item_pressed")
	
func _on_magic_pressed() -> void:
	print("magic_pressed")
	
func _on_melee_pressed() -> void:
	if not awaiting_user_input:
		return
		
	awaiting_user_input = false
		
	var attacker := all_combatants[current_turn_index]
	var target := enemies[0]
	
	target.take_damage(25.0)
	
	print("%s takes melee damage from %s!" % [target.combatant_name, attacker.combatant_name])
	
	current_turn_index += 1
	await get_tree().create_timer(1.0).timeout
	next_turn()
