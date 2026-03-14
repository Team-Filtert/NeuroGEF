extends Node

var items: Array[ItemStack] = []
var money := 0

func add_item(item: Item, amount: int):
	var index := items.find_custom(func(i:ItemStack): return i.item.display_name == item.display_name)
	if index == -1:
		var stack := ItemStack.new()
		stack.item = item
		stack.amount = amount
		items.append(stack)
	else:
		items[index].amount += amount
