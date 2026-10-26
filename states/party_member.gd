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
	# Loaded members keep the HP/MP they were saved with, so mark the resource as
	# initialized; otherwise the first battle would refill them.
	member._initialized = true
	for path in data.get("action_paths", []):
		member.actions.append(load(path))
	var weapon_path := str(data.get("weapon_path", ""))
	if not weapon_path.is_empty():
		member.weapon = load(weapon_path)
	for path in data.get("armor_paths", []):
		member.armors.append(load(path))
	for path in data.get("artifact_paths", []):
		member.artifacts.append(load(path))

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
		"weapon_path": weapon.resource_path if weapon != null else "",
		"armor_paths": armors.map(func(item: ItemEquipable): return item.resource_path),
		"artifact_paths": artifacts.map(func(item: ItemEquipable): return item.resource_path),
	}
