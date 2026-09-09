@tool
class_name DialogicKeyEvent
extends DialogicEvent

## Event that sets, counts up or erases one of the game's persistence keys.
## Keys are the flags the rest of the game remembers things with, so this is how a
## timeline records that something happened and how it advances a quest goal.


enum Operations {
	SET, 	## Sets the key to a value.
	ADD, 	## Adds a number to the key, for counters like "collected 3 of 5".
	ERASE, 	## Removes the key again.
}

enum ValueTypes {BOOL, NUMBER, STRING, EXPRESSION}

const GameRegistry := preload("res://addons/dialogic_additions/PersistenceKeys/game_registry.gd")

### Settings

## Name of the key to change.
@export var key := ""
## What to do with the key (see [enum Operations]).
@export var operation := Operations.SET
## How [member value] should be interpreted (see [enum ValueTypes]).
@export var value_type := ValueTypes.BOOL
## The value to set, as text. Interpreted based on [member value_type].
@export var value := "true"
## The number to add when [member operation] is [constant Operations.ADD].
@export var amount := 1.0


#region EXECUTE
################################################################################

func _execute() -> void:
	var keys: Variant = dialogic.get_subsystem("Keys")
	if keys == null:
		printerr("[Dialogic] The Key event needs the Keys subsystem, but it is missing.")
		finish()
		return

	if key.is_empty():
		printerr("[Dialogic] A Key event has no key name.")
		finish()
		return

	match operation:
		Operations.SET:
			keys.set_value(key, _interpret_value())
		Operations.ADD:
			keys.increment(key, _whole_number(amount))
		Operations.ERASE:
			keys.erase(key)

	finish()


## Keeps whole numbers as integers, so a counter shown in dialogue reads "5" and not "5.0".
func _whole_number(number: float) -> Variant:
	if is_equal_approx(number, roundf(number)):
		return int(number)
	return number


## Turns the stored text into the value that should actually be written.
func _interpret_value() -> Variant:
	match value_type:
		ValueTypes.BOOL:
			return value.strip_edges().to_lower() in ["true", "1", "yes"]

		ValueTypes.NUMBER:
			if value.is_valid_int():
				return value.to_int()
			return value.to_float()

		ValueTypes.EXPRESSION:
			return dialogic.Expressions.execute_string(value)

		_:
			return dialogic.VAR.parse_variables(value)

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Key"
	event_description = "Sets, counts up or erases a persistence key. Read it back with the If Key event."
	set_default_color('Color6')
	event_category = "Logic"
	event_sorting_index = 10

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "key"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name	: property_info
		"name"		: {"property": "key", "default": ""},
		"op"		: {"property": "operation", "default": Operations.SET,
						"suggestions": func(): return {
							"Set": {'value': Operations.SET, 'text_alt': ['set']},
							"Add": {'value': Operations.ADD, 'text_alt': ['add', 'increment']},
							"Erase": {'value': Operations.ERASE, 'text_alt': ['erase', 'remove']},
						}},
		"type"		: {"property": "value_type", "default": ValueTypes.BOOL,
						"suggestions": func(): return {
							"Bool": {'value': ValueTypes.BOOL, 'text_alt': ['bool']},
							"Number": {'value': ValueTypes.NUMBER, 'text_alt': ['number', 'num']},
							"Text": {'value': ValueTypes.STRING, 'text_alt': ['text', 'string']},
							"Expression": {'value': ValueTypes.EXPRESSION, 'text_alt': ['expression', 'expr']},
						}},
		"value"		: {"property": "value", "default": "true"},
		"amount"	: {"property": "amount", "default": 1.0},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('operation', ValueType.FIXED_OPTIONS, {'options': [
			{
				'label': 'Set key',
				'value': Operations.SET,
			},
			{
				'label': 'Count up key',
				'value': Operations.ADD,
			},
			{
				'label': 'Erase key',
				'value': Operations.ERASE,
			}
		]})
	add_header_edit('key', ValueType.DYNAMIC_OPTIONS, {
			'suggestions_func'	: get_key_suggestions,
			'placeholder'		: "Select Key",
			'editor_icon'		: ["Node", "EditorIcons"],
			'tooltip'			: "Keys used elsewhere in the project are listed. You can also type a new one.",
		})
	add_header_edit('amount', ValueType.NUMBER, {'left_text': "by"}, 'operation == Operations.ADD')
	add_header_edit('value_type', ValueType.FIXED_OPTIONS, {
			'left_text'		: "to",
			'symbol_only'	: true,
			'options': [
				{
					'label': 'Bool',
					'icon': ["bool", "EditorIcons"],
					'value': ValueTypes.BOOL,
				},
				{
					'label': 'Number',
					'icon': ["float", "EditorIcons"],
					'value': ValueTypes.NUMBER,
				},
				{
					'label': 'Text',
					'icon': ["String", "EditorIcons"],
					'value': ValueTypes.STRING,
				},
				{
					'label': 'Expression',
					'icon': ["Variant", "EditorIcons"],
					'value': ValueTypes.EXPRESSION,
				}
			]}, 'operation == Operations.SET')
	add_header_edit('value', ValueType.FIXED_OPTIONS, {'options': [
			{
				'label': 'true',
				'value': "true",
			},
			{
				'label': 'false',
				'value': "false",
			}
		]}, 'operation == Operations.SET and value_type == ValueTypes.BOOL')
	add_header_edit('value', ValueType.SINGLELINE_TEXT, {
			'placeholder': "value",
		}, 'operation == Operations.SET and value_type != ValueTypes.BOOL')

## Lists the keys used elsewhere in the project, and keeps whatever is typed usable.
func get_key_suggestions(filter: String) -> Dictionary:
	var suggestions := {}

	for known_key: String in GameRegistry.get_keys():
		suggestions[known_key] = {'value': known_key, 'editor_icon': ["Node", "EditorIcons"]}

	if not filter.is_empty() and not filter in suggestions:
		suggestions[filter] = {'value': filter, 'editor_icon': ["Add", "EditorIcons"]}

	return suggestions

#endregion
