@tool
extends DialogicEvent
class_name DialogicMoveEvent

# Define properties of the event here
var character_path := ""
var direction := CutsceneManager.DirectionOption.UP
var distance := 50.0
var speed := 20.0

func _execute() -> void:
	# This will execute when the event is reached
	CutsceneManager.move(character_path, direction, distance, speed)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Move"
	event_description = "Move a character"
	event_category = "Main"
	event_sorting_index = 2



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "move"

func get_shortcode_parameters() -> Dictionary:
	return {
		"character_path" : {"property": "character_path", "default": ""},
		"direction" : {"property": "direction", "default": CutsceneManager.DirectionOption.UP},
		"distance" : {"property": "distance", "default": 50.0},
		"speed" : {"property": "speed", "default": 20.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('character_path', ValueType.SINGLELINE_TEXT, {'left_text':'Move the character at path'})
	add_body_edit('direction',ValueType.FIXED_OPTIONS, {'left_text':'Direction:', 'options': [
		{
			'label': 'up',
			'value': CutsceneManager.DirectionOption.UP,
		},
		{
			'label': 'down',
			'value': CutsceneManager.DirectionOption.DOWN,
		},
		{
			'label': 'left',
			'value': CutsceneManager.DirectionOption.LEFT,
		},
		{
			'label': 'right',
			'value': CutsceneManager.DirectionOption.RIGHT,
		},
	]})
	add_body_edit('distance', ValueType.NUMBER, {'left_text':'Distance:'})
	add_body_edit('speed', ValueType.NUMBER, {'left_text':'Speed:'})

#endregion
