extends Node

enum ItemType {
	NONE,
	WEPON,
	ARMOR,
	COLLECTABLE,
	CONSUMABLE,
}

var weapons: Array[ItemWepon] = []
var armors: Array[ItemArmor] = []
var collectables: Array[ItemCollectable] = []
var consumables: Array[ItemConsumable] = []

var money := 0

func perform_transaction(
	item: Item = null,
	item_type: ItemType = ItemType.NONE,
	money_amount: int = 0
	):
	money += money_amount
	if item_type != ItemType.NONE:
		add_item(item, item_type)

func add_item(item: Item, item_type: ItemType):
	var items := _get_items(item_type)
	var index := items.find_custom(
		func(i: Item): return i.display_name == item.display_name
	)
	if index == -1:
		items.append(item)
	else:
		items[index].amount += item.amount
		if items[index].amount < 1:
			items.remove_at(index)

func _get_items(item_type: ItemType) -> Array[Item]:
	match item_type:
		ItemType.WEPON:
			return weapons as Array[Item]
		ItemType.ARMOR:
			return armors as Array[Item]
		ItemType.COLLECTABLE:
			return collectables as Array[Item]
		ItemType.CONSUMABLE:
			return consumables as Array[Item]
		_:
			printerr("uknown item type")
			return collectables as Array[Item]
