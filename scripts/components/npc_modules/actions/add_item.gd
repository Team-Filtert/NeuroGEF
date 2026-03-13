class_name NpcActionAddItem
extends NpcActionBase

@export var item: Item
@export var amount := 1

func _preform_action() -> void:
	for i in range(amount):
		Inventory.inventory.append(item)
