class_name PartyMember
extends CombatantData

var level: int = 1
var xp: int = 0


static func from_dict(data: Dictionary) -> PartyMember:
	var member = PartyMember.new()

	member.display_name = data["display_name"]
	member.texture = load(data["texture_path"])
	member.max_health = data["max_health"]
	member.health = data["health"]
	member.max_mana = data["max_mana"]
	member.mana = data["mana"]
	member.attack = data["attack"]
	member.magic = data["magic"]
	member.defense = data["defense"]
	member.speed = data["speed"]
	member.accuracy = data.get("accuracy", 0)
	member.level = data["level"]
	member.xp = data["xp"]
	for path in data.get("action_paths", []):
		member.actions.append(load(path))

	return member


func to_dict() -> Dictionary:
	return {
		"display_name": display_name,
		"texture_path": texture.resource_path if texture != null else "",
		"max_health": max_health,
		"health": health,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"magic": magic,
		"defense": defense,
		"speed": speed,
		"accuracy": accuracy,
		"level": level,
		"xp": xp,
		"action_paths": actions.map(func(action: ActionBase): return action.resource_path),
	}
