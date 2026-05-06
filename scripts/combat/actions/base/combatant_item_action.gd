class_name CombatantItemAction
extends CombatantAction

var item: ItemConsumable

func destroy_item():
	if item.amount > 1:
		item.amount -= 1
	else:
		InventoryManager.consumables.erase(item)
