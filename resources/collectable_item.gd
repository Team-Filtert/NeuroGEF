class_name CollectableItem
extends Item

@export var description: String

static func from_dict(data: Dictionary) -> CollectableItem:
	var collectable_item := CollectableItem.new()

	collectable_item.display_name = data["display_name"]
	collectable_item.description = data["description"]
	collectable_item.quantity = data["quantity"]

	return collectable_item

func to_dict() -> Dictionary:
	return {
		"display_name": display_name,
		"description": description,
		"quantity": quantity
	}
