extends Node2D

func _ready() -> void:
	var party_member_data: CombatantData = load("res://resources/combatants/party_member.tres")
	var evil_scene: PackedScene = load("res://scenes/characters/evil.tscn")
	var evil_node: NpcStandardTemplate = evil_scene.instantiate()
	PartyManager.add_member(party_member_data, evil_node)
