extends Node

var weapons: Array[ItemStack] = []
var armors: Array[ItemStack] = []
var collectables: Array[ItemStack] = []
var consumables: Array[ItemStack] = []

var money := 0

func perform_transaction(item_type: Item, item_amount: int, money_amount: int):
	var items := get_items(item_type)
	money += money_amount
	var index := items.find_custom(
		func(i:ItemStack): return i.item.display_name == item_type.display_name
	)
	if index == -1:
		var stack := ItemStack.new()
		stack.item = item_type
		stack.amount = item_amount
		items.append(stack)
	else:
		items[index].amount += item_amount
		if items[index].amount < 1:
			items.remove_at(index)

func get_items(item_type: Item) -> Array[ItemStack]:
	if item_type is ItemWepon:
		return weapons
	elif item_type is ItemArmor:
		return armors
	elif item_type is ItemCollectable:
		return collectables
	else:
		return consumables
