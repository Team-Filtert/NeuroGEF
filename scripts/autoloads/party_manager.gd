extends Node

var party: Array[CombatantData] = []

func _ready() -> void:
	var player_data: CombatantData = preload("res://resources/combatants/player_base.tres")
	var party_member_data: CombatantData = preload("res://resources/combatants/party_member_base.tres")
	
	add_member(player_data)
	
	# Add the aditional 2 party members
	add_member(party_member_data)
	add_member(party_member_data)

func add_member(member: CombatantData) -> void:
	if party.size() >= 3:
		return
		
	party.append(member)
	
func remove_member(member: CombatantData) -> void:
	party.erase(member)
