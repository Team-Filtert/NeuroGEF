@tool
extends DialogicEvent
class_name DialogicToggleLoopEvent

# Define properties of the event here
var npc_path := ""
var loop_name := ""

func _execute() -> void:
	# This will execute when the event is reached
	CutsceneManager.toggle_loop(npc_path, loop_name)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Toggle Loop"
	event_description = "Start or stop an npc from looping"
	event_category = "Main"
	event_sorting_index = 5



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "toggle_loop"

func get_shortcode_parameters() -> Dictionary:
	return {
		"npc_path" : {"property": "npc_path", "default": ""},
		"loop_name" : {"property": "loop_name", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('npc_path', ValueType.SINGLELINE_TEXT, {'left_text':'Toggle the looping of the npc at path'})
	add_body_edit('loop_name', ValueType.SINGLELINE_TEXT, {'left_text':'Loop Name:'})

#endregion
