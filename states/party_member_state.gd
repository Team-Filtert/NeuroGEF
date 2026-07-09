class_name PartyMemberState
extends RefCounted

var max_health: int
var health: int
var max_mana
var mana: int
var attack: int
var magic: int
var defense: int
var speed: int
var accuracy: int

static func from_dict(data: Dictionary) -> PartyMemberState:
	var member = PartyMemberState.new()
	
	member.max_health = data["max_health"]
	member.health = data["health"]
	member.max_mana = data["max_mana"]
	member.mana = data["mana"]
	member.attack = data["attack"]
	member.magic = data["magic"]
	member.defense = data["defense"]
	member.speed = data["speed"]
	member.accuracy = data["accuracy"]
	
	return member

func to_dict() -> Dictionary:
	return {
		"max_health": max_health,
		"health": health,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"accuracy": accuracy,
	}
