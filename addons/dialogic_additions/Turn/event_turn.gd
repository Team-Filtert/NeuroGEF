@tool
extends DialogicEvent
class_name DialogicTurnEvent

# Define properties of the event here
var character_path := ""
var direction := CutsceneManager.DirectionOption.UP

func _execute() -> void:
	# This will execute when the event is reached
	var animation_name: StringName
	match direction:
		CutsceneManager.DirectionOption.UP:
			animation_name = "idle_up"
		CutsceneManager.DirectionOption.DOWN:
			animation_name = "idle_down"
		CutsceneManager.DirectionOption.LEFT:
			animation_name = "idle_left"
		CutsceneManager.DirectionOption.RIGHT:
			animation_name = "idle_right"
	CutsceneManager.animate(character_path, animation_name)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Turn"
	event_description = "Turn a character"
	event_category = "Main"
	event_sorting_index = 4



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "turn"

func get_shortcode_parameters() -> Dictionary:
	return {
		"character_path" : {"property": "character_path", "default": ""},
		"direction" : {"property": "direction", "default": CutsceneManager.DirectionOption.UP},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('character_path', ValueType.SINGLELINE_TEXT, {'left_text':'Turn the character at path'})
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

#endregion
