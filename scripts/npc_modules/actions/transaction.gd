class_name NpcActionTransaction
extends NpcActionBase

@export var item: Item
@export var item_type := Inventory.ItemType.NONE
@export var item_amount := 0
@export var money_amount := 0

func _preform_action() -> void:
	item.amount = item_amount
	Inventory.perform_transaction(item, item_type, money_amount)
