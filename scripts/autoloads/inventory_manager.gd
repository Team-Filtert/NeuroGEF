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
	) -> void:
	money += money_amount
	if item_type != ItemType.NONE:
		_add_item(item, item_type)

func _add_item(item: Item, item_type: ItemType) -> void:
	match item_type:
		ItemType.WEPON:
			_add_weapon(item)
		ItemType.ARMOR:
			_add_armor(item)
		ItemType.COLLECTABLE:
			_add_collectable(item)
		ItemType.CONSUMABLE:
			_add_consumable(item)
		ItemType.NONE:
			printerr("item type is NONE")
		_:
			printerr("item type is uknown")


func _add_weapon(weapon: ItemWepon) -> void:
	var index := weapons.find_custom(
		func(w: ItemWepon): return w.display_name == weapon.display_name
	)
	if index == -1:
		weapons.append(weapon)
	else:
		weapons[index].amount += weapon.amount
		if weapons[index].amount < 1:
			weapons.remove_at(index)

func _add_armor(armor: ItemArmor) -> void:
	var index := armors.find_custom(
		func(a: ItemArmor): return a.display_name == armor.display_name
	)
	if index == -1:
		armors.append(armor)
	else:
		armors[index].amount += armor.amount
		if armors[index].amount < 1:
			armors.remove_at(index)

func _add_collectable(collectable: ItemCollectable) -> void:
	var index := collectables.find_custom(
		func(c: ItemCollectable): return c.display_name == collectable.display_name
	)
	if index == -1:
		collectables.append(collectable)
	else:
		collectables[index].amount += collectable.amount
		if collectables[index].amount < 1:
			collectables.remove_at(index)

func _add_consumable(consumable: ItemConsumable) -> void:
	var index := consumables.find_custom(
		func(c: ItemConsumable): return c.display_name == consumable.display_name
	)
	if index == -1:
		consumables.append(consumable)
	else:
		consumables[index].amount += consumable.amount
		if consumables[index].amount < 1:
			consumables.remove_at(index)
