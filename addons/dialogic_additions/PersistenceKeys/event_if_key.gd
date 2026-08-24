@tool
class_name DialogicIfKeyEvent
extends DialogicEvent

## Branch event that only plays the events it contains if a persistence key matches.
##
## This is the Condition event narrowed down to keys, so the key can be picked from a
## dropdown instead of written as an expression. For anything more involved (combining
## several checks with `and`/`or`) use the normal Condition event with
## `Dialogic.get_subsystem("Keys").is_true("my_key")`.


enum Checks {
	IS_TRUE, 	## The key is set to something truthy.
	IS_FALSE, 	## The key is missing or set to something falsy.
	EXISTS, 	## The key was set at some point, whatever its value.
	NOT_EXISTS, ## The key was never set, or was erased again.
	EQUALS, 	## The key holds exactly this value.
	NOT_EQUALS, ## The key holds anything but this value.
	AT_LEAST, 	## The key is a number of at least this much.
	AT_MOST, 	## The key is a number of at most this much.
}

enum ValueTypes {BOOL, NUMBER, STRING}

const GameRegistry := preload("res://addons/dialogic_additions/PersistenceKeys/game_registry.gd")

### Settings

## Name of the key to check.
@export var key := ""
## What to check about the key (see [enum Checks]).
@export var check := Checks.IS_TRUE
## How [member value] should be interpreted (see [enum ValueTypes]).
@export var value_type := ValueTypes.BOOL
## The value to compare against, as text. Interpreted based on [member value_type].
@export var value := "true"
## The number to compare against for [constant Checks.AT_LEAST] and [constant Checks.AT_MOST].
@export var number := 1.0


#region EXECUTE
################################################################################

func _execute() -> void:
	if not _matches():
		dialogic.current_event_idx = get_end_branch_index()

	finish()


func _is_branch_starter() -> bool:
	return true


func _matches() -> bool:
	var keys: Variant = dialogic.get_subsystem("Keys")
	if keys == null:
		printerr("[Dialogic] The If Key event needs the Keys subsystem, but it is missing.")
		return false

	if key.is_empty():
		printerr("[Dialogic] An If Key event has no key name.")
		return false

	match check:
		Checks.IS_TRUE:
			return keys.is_true(key)
		Checks.IS_FALSE:
			return not keys.is_true(key)
		Checks.EXISTS:
			return keys.has(key)
		Checks.NOT_EXISTS:
			return not keys.has(key)
		Checks.EQUALS:
			return keys.equals(key, _interpret_value())
		Checks.NOT_EQUALS:
			return not keys.equals(key, _interpret_value())
		Checks.AT_LEAST:
			return keys.at_least(key, number)
		Checks.AT_MOST:
			return keys.has(key) and keys.get_number(key, INF) <= number

	return false


## Turns the stored text into the value that should be compared against.
func _interpret_value() -> Variant:
	match value_type:
		ValueTypes.BOOL:
			return value.strip_edges().to_lower() in ["true", "1", "yes"]

		ValueTypes.NUMBER:
			if value.is_valid_int():
				return value.to_int()
			return value.to_float()

		_:
			return dialogic.VAR.parse_variables(value)

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "If Key"
	event_description = "Plays the events it contains only if a persistence key matches."
	set_default_color('Color3')
	event_category = "Flow"
	event_sorting_index = 2
	can_contain_events = true


func _get_end_branch_control() -> Control:
	return load("res://addons/dialogic_additions/PersistenceKeys/ui_branch_end.tscn").instantiate()


## Shown on the end branch node in the visual editor.
func get_branch_end_text() -> String:
	if key.is_empty():
		return "IF KEY"
	return "IF KEY (" + key + " " + _check_label() + ")"


func _check_label() -> String:
	match check:
		Checks.IS_TRUE:
			return "is true"
		Checks.IS_FALSE:
			return "is false"
		Checks.EXISTS:
			return "exists"
		Checks.NOT_EXISTS:
			return "doesn't exist"
		Checks.EQUALS:
			return "== " + value
		Checks.NOT_EQUALS:
			return "!= " + value
		Checks.AT_LEAST:
			return ">= " + str(number)
		Checks.AT_MOST:
			return "<= " + str(number)
	return ""

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "if_key"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name	: property_info
		"name"		: {"property": "key", "default": ""},
		"is"		: {"property": "check", "default": Checks.IS_TRUE,
						"suggestions": func(): return {
							"Is true": {'value': Checks.IS_TRUE, 'text_alt': ['true']},
							"Is false": {'value': Checks.IS_FALSE, 'text_alt': ['false']},
							"Exists": {'value': Checks.EXISTS, 'text_alt': ['exists']},
							"Doesn't exist": {'value': Checks.NOT_EXISTS, 'text_alt': ['missing']},
							"Equals": {'value': Checks.EQUALS, 'text_alt': ['==']},
							"Doesn't equal": {'value': Checks.NOT_EQUALS, 'text_alt': ['!=']},
							"At least": {'value': Checks.AT_LEAST, 'text_alt': ['>=']},
							"At most": {'value': Checks.AT_MOST, 'text_alt': ['<=']},
						}},
		"type"		: {"property": "value_type", "default": ValueTypes.BOOL,
						"suggestions": func(): return {
							"Bool": {'value': ValueTypes.BOOL, 'text_alt': ['bool']},
							"Number": {'value': ValueTypes.NUMBER, 'text_alt': ['number']},
							"Text": {'value': ValueTypes.STRING, 'text_alt': ['text']},
						}},
		"value"		: {"property": "value", "default": "true"},
		"number"	: {"property": "number", "default": 1.0},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("If key")
	add_header_edit('key', ValueType.DYNAMIC_OPTIONS, {
			'suggestions_func'	: get_key_suggestions,
			'placeholder'		: "Select Key",
			'editor_icon'		: ["Node", "EditorIcons"],
			'tooltip'			: "Keys used elsewhere in the project are listed. You can also type a new one.",
		})
	add_header_edit('check', ValueType.FIXED_OPTIONS, {'options': [
			{'label': 'is true', 'value': Checks.IS_TRUE},
			{'label': 'is false', 'value': Checks.IS_FALSE},
			{'label': 'exists', 'value': Checks.EXISTS},
			{'label': "doesn't exist", 'value': Checks.NOT_EXISTS},
			{'label': 'equals', 'value': Checks.EQUALS},
			{'label': "doesn't equal", 'value': Checks.NOT_EQUALS},
			{'label': 'is at least', 'value': Checks.AT_LEAST},
			{'label': 'is at most', 'value': Checks.AT_MOST},
		]})
	add_header_edit('number', ValueType.NUMBER, {},
			'check == Checks.AT_LEAST or check == Checks.AT_MOST')
	add_header_edit('value_type', ValueType.FIXED_OPTIONS, {
			'symbol_only'	: true,
			'options': [
				{'label': 'Bool', 'icon': ["bool", "EditorIcons"], 'value': ValueTypes.BOOL},
				{'label': 'Number', 'icon': ["float", "EditorIcons"], 'value': ValueTypes.NUMBER},
				{'label': 'Text', 'icon': ["String", "EditorIcons"], 'value': ValueTypes.STRING},
			]}, 'check == Checks.EQUALS or check == Checks.NOT_EQUALS')
	add_header_edit('value', ValueType.FIXED_OPTIONS, {'options': [
			{'label': 'true', 'value': "true"},
			{'label': 'false', 'value': "false"},
		]}, '(check == Checks.EQUALS or check == Checks.NOT_EQUALS) and value_type == ValueTypes.BOOL')
	add_header_edit('value', ValueType.SINGLELINE_TEXT, {'placeholder': "value"},
			'(check == Checks.EQUALS or check == Checks.NOT_EQUALS) and value_type != ValueTypes.BOOL')


## Lists the keys used elsewhere in the project, and keeps whatever is typed usable.
func get_key_suggestions(filter: String) -> Dictionary:
	var suggestions := {}

	for known_key: String in GameRegistry.get_keys():
		suggestions[known_key] = {'value': known_key, 'editor_icon': ["Node", "EditorIcons"]}

	if not filter.is_empty() and not filter in suggestions:
		suggestions[filter] = {'value': filter, 'editor_icon': ["Add", "EditorIcons"]}

	return suggestions

#endregion
