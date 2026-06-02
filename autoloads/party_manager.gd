extends Node

@onready var party_container: Node2D = $/root/Root/PartyContainer

var combat_party: Array[CombatantData] = []
var overworld_party: Array[CharacterBase] = []

func _ready() -> void:
	var player_data: CombatantData = preload("res://data/player_base.tres")
	
	combat_party.append(player_data)
	
	for character in party_container.get_children():
		overworld_party.append(character)

func add_member(member: CombatantData, character: NpcTemplateBase) -> void:
	if overworld_party.size() >= 3:
		return
		
	combat_party.append(member)
	overworld_party.append(character)
	party_container.add_child(character)
	character.owner = get_tree().edited_scene_root
	
func remove_member(member: CombatantData, character: NpcTemplateBase) -> void:
	combat_party.erase(member)
	overworld_party.erase(character)
	party_container.remove_child(character)
