class_name PartyMember
extends CombatantData

var level: int
var xp: int

static func from_dict(data: Dictionary) -> PartyMember:
	var member = PartyMember.new()
	
	member.texture = load(data["texture_path"])
	member.max_health = data["max_health"]
	member.health = data["health"]
	member.max_mana = data["max_mana"]
	member.mana = data["mana"]
	member.attack = data["attack"]
	member.magic = data["magic"]
	member.defense = data["defense"]
	member.speed = data["speed"]
	member.accuracy = data["accuracy"]
	member.level = data["level"]
	member.xp = data["xp"]
	
	return member

func to_dict() -> Dictionary:
	return {
		"texture_path": texture.resource_path,
		"max_health": max_health,
		"health": health,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"accuracy": accuracy,
		"level": level,
		"xp": xp,
	}
