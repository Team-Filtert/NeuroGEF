class_name ConsumableItem
extends Item

@export var hp_restore: int

static func from_dict(data: Dictionary) -> ConsumableItem:
	var consumable_item := ConsumableItem.new()

	consumable_item.display_name = data["display_name"]
	consumable_item.hp_restore = data["hp_restore"]
	consumable_item.quantity = data["quantity"]

	return consumable_item

func to_dict() -> Dictionary:
	return {
		"display_name": display_name,
		"hp_restore": hp_restore,
		"quantity": quantity
	}
