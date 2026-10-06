class_name Inventory
extends RefCounted

## The party's items and money. Items stack by [member Item.id]; saves store the
## resource path so they can be reloaded.

var money: int = 0

var _counts: Dictionary = {}
var _by_id: Dictionary = {}


func add(item: Item, amount := 1) -> void:
	if item == null or amount <= 0:
		return
	_by_id[item.id] = item
	_counts[item.id] = int(_counts.get(item.id, 0)) + amount


func remove(id: StringName, amount := 1) -> bool:
	if int(_counts.get(id, 0)) < amount:
		return false
	_counts[id] = int(_counts[id]) - amount
	if _counts[id] <= 0:
		_counts.erase(id)
		_by_id.erase(id)
	return true


func count(id: StringName) -> int:
	return int(_counts.get(id, 0))


func has(id: StringName) -> bool:
	return int(_counts.get(id, 0)) > 0


func get_item(id: StringName) -> Item:
	return _by_id.get(id)


func items() -> Array[Item]:
	var out: Array[Item] = []
	for id in _counts:
		out.append(_by_id[id])
	return out


func equipables() -> Array[ItemEquipable]:
	var out: Array[ItemEquipable] = []
	for item in items():
		if item is ItemEquipable:
			out.append(item)
	return out


func consumables() -> Array[Consumable]:
	var out: Array[Consumable] = []
	for item in items():
		if item is Consumable:
			out.append(item)
	return out


## Uses a consumable on a party member outside combat and removes one.
func use_consumable(id: StringName, member: CombatantData) -> bool:
	var item := get_item(id)
	if not has(id) or not (item is Consumable):
		return false
	(item as Consumable).use_out_of_combat(member)
	remove(id)
	return true


func to_dict() -> Dictionary:
	var entries: Array = []
	for id in _counts:
		entries.append({"path": _by_id[id].resource_path, "amount": int(_counts[id])})
	return {"money": money, "items": entries}


func from_dict(data: Dictionary) -> void:
	money = int(data.get("money", 0))
	_counts.clear()
	_by_id.clear()
	for entry in data.get("items", []):
		var item := load(str(entry.get("path", ""))) as Item
		if item != null:
			add(item, int(entry.get("amount", 1)))
