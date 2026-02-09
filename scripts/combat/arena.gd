class_name Arena
extends Node2D

signal battle_ended

@onready var attack_button: Button = $UI/PanelContainer/VBoxContainer/AttackButton
@onready var flee_button: Button = $UI/PanelContainer/VBoxContainer/FleeButton
@onready var party_slots: Array[Marker2D] = [$Party/Slot1, $Party/Slot2, $Party/Slot3]
@onready var enemy_slots: Array[Marker2D] = [$Enemies/Slot1, $Enemies/Slot2, $Enemies/Slot3]

enum CombatState {
	PLAYER_INPUT
}

var action_queue: Array[CombatAction] = []
var current_state := CombatState.PLAYER_INPUT
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
	current_state = CombatState.PLAYER_INPUT
	selected_party_member_index = 0
	selected_target_index = 0
	action_queue.clear()
	party.clear()
	enemies.clear()
	
	for combatant in all_combatants:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
func spawn_combatants(combatants: Array[CombatantData], slots: Array[Marker2D], parent: Node2D, output_array: Array[Combatant]) -> void:
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	for i in combatants.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup_from_data(combatants[i])
		# TODO: Use proper sprites, scale down current ones for now
		combatant.scale = Vector2(0.3, 0.3)
		combatant.position = slots[i].position
		parent.add_child(combatant)
		output_array.append(combatant)
		
func _start_player_input_phase() -> void:
	pass
		
func _on_attack_pressed() -> void:
	if current_state != CombatState.PLAYER_INPUT:
		return
		
	var action := CombatAction.new()
	
	action.type = CombatAction.Type.ATTACK
	action.source = party[selected_party_member_index]
	action.target = enemies[selected_target_index]
	action_queue.append(action)
	
func _on_flee_pressed() -> void:
	flee_button.pressed.disconnect(_on_flee_pressed)
	battle_ended.emit()
	
#enum CombatState {
#	PLAYER_INPUT,
#	ENEMY_TURN,
#	RESOLVING_ACTIONS,
#}
#
#var party: Array[Combatant] = []
#var enemies: Array[Combatant] = []
#var all_combatants: Array[Combatant] = []
#var action_queue: Array[Dictionary] = []
#var current_state := CombatState.PLAYER_INPUT
#var current_party_member_index := 0
#var current_target_index := 0
#
#func _unhandled_input(event: InputEvent) -> void:
#	match current_state:
#		CombatState.PLAYER_INPUT:
#			if event.is_action_pressed("ui_right"):
#				var old_index := current_target_index
#				current_target_index = wrapi(current_target_index + 1, 0, enemies.size())
#						
#				enemies[old_index].hide_highlight()
#				enemies[current_target_index].show_highlight()
#				
#				print("Selected enemy at index %s" % current_target_index)
#					
#				get_viewport().set_input_as_handled()
#			elif event.is_action_pressed("ui_left"):
#				var old_index := current_target_index
#				current_target_index = wrapi(current_target_index - 1, 0, enemies.size())
#						
#				enemies[old_index].hide_highlight()
#				enemies[current_target_index].show_highlight()
#				
#				print("Selected enemy at index %s" % current_target_index)
#						
#				get_viewport().set_input_as_handled()
#				
#func setup_battle() -> void:
#	spawn_party()
#	spawn_enemies()
#	all_combatants = party + enemies
#	enemies[current_target_index].show_highlight()
#	
#	attack_button.pressed.connect(_on_attack_pressed)
#	flee_button.pressed.connect(_on_flee_pressed, CONNECT_ONE_SHOT)
#	
#	_start_player_input_phase()
#	
#func _start_player_input_phase() -> void:
#	current_state = CombatState.PLAYER_INPUT
#	current_party_member_index = 0
#	current_target_index = 0
#	action_queue.clear()
#	
#	party[current_party_member_index].show_highlight()
#	enemies[current_target_index].show_highlight()

#func cleanup_battle() -> void:
#	current_state = CombatState.PLAYER_INPUT
#	current_party_member_index = 0
#	current_target_index = 0
#	action_queue.clear()
#	party.clear()
#	enemies.clear()
#	
#	for combatant in all_combatants:
#		if is_instance_valid(combatant):
#			combatant.queue_free()
#
#func _on_attack_pressed() -> void:
#	if current_state != CombatState.PLAYER_INPUT:
#		return
#		
#	action_queue.append({
#		"type": "attack",
#		"source": party[current_party_member_index],
#		"target": enemies[current_target_index]
#	})
#	
#	print("Party member action: %s | %s | Enemy %s" % ["attack", party[current_party_member_index].display_name, current_target_index])
#	
#	party[current_party_member_index].hide_highlight()
#	enemies[current_target_index].hide_highlight()
#	
#	current_party_member_index += 1
#	
#	if current_party_member_index >= party.size():
#		current_state = CombatState.ENEMY_TURN
#		
#		for enemy in enemies:
#			var target: Combatant = party.pick_random()
#			
#			action_queue.append({
#				"type": "attack",
#				"source": enemy,
#				"target": target
#			})
#			
#			print("Enemy action: %s | %s | %s" % ["attack", enemy.display_name, target.display_name])
#			
#		current_party_member_index = 0
#		
#		current_state = CombatState.RESOLVING_ACTIONS
#		
#		print(action_queue)
#		
#		for action in action_queue:
#			match action.type:
#				"attack":
#					print("Attack resolved! %s -> %s" % [action.source.display_name, action.target.display_name])
#					action.target.take_damage(action.source.attack)
#					await get_tree().create_timer(1.0).timeout
#					
#		party = party.filter(func(c): return c.health > 0)
#		enemies = enemies.filter(func(c): return c.health > 0)
#		
#		if party.size() == 0:
#			print("Enemies win...")
#			battle_ended.emit()
#			return
#			
#		if enemies.size() == 0:
#			print("Party wins!")
#			battle_ended.emit()
#			return
#					
#		_start_player_input_phase()
#	else:
#		current_target_index = 0
#		
#		party[current_party_member_index].show_highlight()
#		enemies[current_target_index].show_highlight()
#
#func _on_flee_pressed() -> void:
#	battle_ended.emit()
