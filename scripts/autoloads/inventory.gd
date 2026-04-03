class_name Inventory
extends Node

enum ItemType {
	NONE,
	WEPON,
	ARMOR,
	COLLECTABLE,
	CONSUMABLE,
}

var weapons: Array[ItemStack] = []
var armors: Array[ItemStack] = []
var collectables: Array[ItemStack] = []
var consumables: Array[ItemStack] = []

var money := 0

func perform_transaction(
	item: Item = null,
	item_type: ItemType = ItemType.NONE,
	item_amount: int = 0,
	money_amount: int = 0
	):
	money += money_amount
	if item_amount != 0:
		add_item(item, item_type, item_amount)

func add_item(item: Item, item_type: ItemType, item_amount: int):
	var items := get_items(item_type)
	var index := items.find_custom(
		func(i:ItemStack): return i.item.display_name == item.display_name
	)
	if index == -1:
		var stack := ItemStack.new()
		stack.item = item
		stack.amount = item_amount
		items.append(stack)
	else:
		items[index].amount += item_amount
		if items[index].amount < 1:
			items.remove_at(index)

func get_items(item_type: ItemType) -> Array[ItemStack]:
	match item_type:
		ItemType.WEPON:
			return weapons
		ItemType.ARMOR:
			return armors
		ItemType.COLLECTABLE:
			return collectables
		ItemType.CONSUMABLE:
			return consumables
		_:
			printerr("uknown item type")
			return collectables

func _ready():
	GameManager.inventory = self
