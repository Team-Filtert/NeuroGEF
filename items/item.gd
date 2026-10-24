class_name Item
extends Resource

## Base inventory item. [ItemEquipable] and [Consumable] extend this.
## The [member id] is the key the [Inventory] and saves use, so keep it stable.

@export var id: StringName = &""
@export var display_name: String = "Item"
@export_multiline var description: String = ""
@export var texture: Texture2D
