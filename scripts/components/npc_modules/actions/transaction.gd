class_name NpcActionTransaction
extends NpcActionBase

@export var item_type: Item
@export var item_amount := 0
@export var money_amount := 0

func _preform_action() -> void:
	Inventory.perform_transaction(item_type, item_amount, money_amount)
