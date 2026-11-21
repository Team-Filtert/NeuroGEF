class_name PartyMember
extends CombatantData

var level: int = 1
var xp: int = 0

@export_group("Overworld Sprite")
## Sprite used while walking around. When empty, the combat sprite is used.
@export var overworld_texture: Texture2D
## Sprite-sheet layout of [member overworld_texture].
@export var overworld_hframes: int = 1
@export var overworld_vframes: int = 1
@export var overworld_frame: int = 0


## Returns the overworld sprite, falling back to the combat sprite when unset.
func get_overworld_texture() -> Texture2D:
	return overworld_texture if overworld_texture != null else texture


func get_overworld_hframes() -> int:
	return overworld_hframes if overworld_texture != null else sprite_hframes


func get_overworld_vframes() -> int:
	return overworld_vframes if overworld_texture != null else sprite_vframes


func get_overworld_frame() -> int:
	return overworld_frame if overworld_texture != null else sprite_frame


static func from_dict(data: Dictionary) -> PartyMember:
	var member = PartyMember.new()

	member.display_name = data["display_name"]
	var texture_path := str(data.get("texture_path", ""))
	if not texture_path.is_empty():
		member.texture = load(texture_path)
	member.sprite_hframes = int(data.get("sprite_hframes", 1))
	member.sprite_vframes = int(data.get("sprite_vframes", 1))
	member.sprite_frame = int(data.get("sprite_frame", 0))
	var overworld_path := str(data.get("overworld_texture_path", ""))
	if not overworld_path.is_empty():
		member.overworld_texture = load(overworld_path)
	member.overworld_hframes = int(data.get("overworld_hframes", 1))
	member.overworld_vframes = int(data.get("overworld_vframes", 1))
	member.overworld_frame = int(data.get("overworld_frame", 0))
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
		"sprite_hframes": sprite_hframes,
		"sprite_vframes": sprite_vframes,
		"sprite_frame": sprite_frame,
		"overworld_texture_path": overworld_texture.resource_path if overworld_texture != null else "",
		"overworld_hframes": overworld_hframes,
		"overworld_vframes": overworld_vframes,
		"overworld_frame": overworld_frame,
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
