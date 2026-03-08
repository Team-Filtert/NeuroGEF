extends Node

var party: Array[CombatantData] = []

@onready var neuro: CharacterBase = $/root/Root/Home/Player
@onready var evil: CharacterBase = $/root/Root/Home/Evil
@onready var companion: CharacterBase = null

func _ready() -> void:
	var player_data: CombatantData = load("res://resources/combatants/player.tres")
	var party_member_data: CombatantData = load("res://resources/combatants/party_member.tres")
	
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
