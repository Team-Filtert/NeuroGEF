class_name Arena
extends Node2D

signal battle_ended

@onready var turn_processor: TurnProcessor = $TurnProcessor

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []

func setup_battle() -> void:
	spawn_party()
	spawn_enemies()
		
	$UI/PanelContainer/VBoxContainer/FleeButton.pressed.connect(_on_flee_pressed)
		
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

func _on_flee_pressed() -> void:
		battle_ended.emit()
		$UI/PanelContainer/VBoxContainer/FleeButton.pressed.disconnect(_on_flee_pressed)
