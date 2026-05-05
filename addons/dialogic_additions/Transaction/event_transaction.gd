@tool
extends DialogicEvent
class_name DialogicTransactionEvent

# Define properties of the event here
var item: String = ""
var item_type: Inventory.ItemType = Inventory.ItemType.NONE
var item_amount := 0
var money_amount := 0

func _execute() -> void:
	# This will execute when the event is reached
	var loaded_item: Item = load(item)
	loaded_item.amount = item_amount
	Inventory.perform_transaction(loaded_item, item_type, money_amount)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Transaction"
	event_description = "Exchange money and items"
	event_category = "Main"
	event_sorting_index = 6



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "transaction"

func get_shortcode_parameters() -> Dictionary:
	return {
		"item" : {"property": "item", "default": ""},
		"item_type" : {"property": "item_type", "default": Inventory.ItemType.NONE},
		"item_amount" : {"property": "item_amount", "default": 0},
		"money_amount" : {"property": "money_amount", "default": 0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('item_amount', ValueType.NUMBER, {'left_text':'Exchange'})
	add_header_edit('item', ValueType.FILE)
	add_header_edit('item_type',ValueType.FIXED_OPTIONS, {'options': [
		{
			'label': 'wepon',
			'value': Inventory.ItemType.WEPON,
		},
		{
			'label': 'armor',
			'value': Inventory.ItemType.ARMOR,
		},
		{
			'label': 'collectable',
			'value': Inventory.ItemType.COLLECTABLE,
		},
		{
			'label': 'consumable',
			'value': Inventory.ItemType.CONSUMABLE,
		},
	]})
	add_header_edit('money_amount', ValueType.NUMBER, {'left_text':'for'})

#endregion
