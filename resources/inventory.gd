class_name Inventory
extends Resource

var collectables: Array[CollectableItem] = []
var consumables: Array[ConsumableItem] = []

static func from_dict(data: Dictionary) -> Inventory:
	var inventory := Inventory.new()

	for i in data["collectables"]:
		inventory.collectables.append(CollectableItem.from_dict(i))

	for i in data["consumables"]:
		inventory.consumables.append(ConsumableItem.from_dict(i))

	return inventory

func to_dict() -> Dictionary:
	return {
		"collectables": collectables.map(func(i): return i.to_dict()),
		"consumables": consumables.map(func(i): return i.to_dict())
	}
