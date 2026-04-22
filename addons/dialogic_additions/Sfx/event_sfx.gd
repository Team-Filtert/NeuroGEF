@tool
extends DialogicEvent
class_name DialogicSfxEvent

# Define properties of the event here
var sfx: String = ""
var player_key: String = ""

func _execute() -> void:
	# This will execute when the event is reached
	AudioManager.play_sfx(load(sfx), player_key)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Sfx"
	event_description = "Plays sfx"
	set_default_color('Color7')
	event_category = "Audio"
	event_sorting_index = 5



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "sfx"

func get_shortcode_parameters() -> Dictionary:
	return {
		"sfx" : {"property": "sfx", "default": ""},
		"player_key" : {"property": "player_key", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('sfx', ValueType.FILE, {
		'left_text': 'Play',
		'placeholder': 'sfx',
	})
	add_header_edit('player_key', ValueType.SINGLELINE_TEXT, {
		'left_text': 'throug',
		'placeholder': 'player_key',
	})

#endregion
