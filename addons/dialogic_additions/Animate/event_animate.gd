@tool
extends DialogicEvent
class_name DialogicAnimateEvent

# Define properties of the event here
var character_name := ""
var animation_name := ""
var is_loop := false

func _execute() -> void:
	# This will execute when the event is reached
	CutsceneManager.animate(character_name, animation_name, is_loop)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Animate"
	event_description = "play one of a characters animations"
	event_category = "Main"
	event_sorting_index = 3


#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "animate"

func get_shortcode_parameters() -> Dictionary:
	return {
		"character_name" : {"property": "character_name", "default": ""},
		"animation_name" : {"property": "animation_name", "default": ""},
		"is_loop" : {"property": "is_loop", "default": false},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('character_name', ValueType.SINGLELINE_TEXT, {'left_text':'Animate the character'})
	add_body_edit('animation_name', ValueType.SINGLELINE_TEXT, {'left_text':'Animation Name:'})
	add_body_edit('animation_name', ValueType.BOOL, {'left_text':'Is A Loop:'})

#endregion
