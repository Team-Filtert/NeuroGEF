@tool
extends DialogicEvent
class_name DialogicToggleFollowEvent

# Define properties of the event here
var npc_path := ""

func _execute() -> void:
	# This will execute when the event is reached
	CutsceneManager.toggle_follow(npc_path)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Toggle Follow"
	event_description = "Start or stop an npc from following"
	event_category = "Main"
	event_sorting_index = 4



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "toggle_follow"

func get_shortcode_parameters() -> Dictionary:
	return {
		"npc_path" : {"property": "npc_path", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('npc_path', ValueType.SINGLELINE_TEXT, {'left_text':'Toggle the following of the npc at path'})

#endregion
