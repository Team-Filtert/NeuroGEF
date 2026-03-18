@tool
extends DialogicEvent
class_name DialogicAwaitEvent

# Define properties of the event here
var character_name: String = ""
var hide_textbox := true

func _execute() -> void:
	# This will execute when the event is reached
	if hide_textbox:
		dialogic.Text.hide_textbox()
	dialogic.current_state = DialogicGameHandler.States.WAITING
	dialogic.Inputs.auto_skip.enabled = false
	var signal_node_name: StringName = ""
	character_name = character_name.to_lower()
	while character_name != signal_node_name:
		signal_node_name = await CutsceneManager.done_action
		signal_node_name = signal_node_name.to_lower()
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Await"
	event_description = "Waits for action to finish"
	set_default_color('Color5')
	event_category = "Flow"
	event_sorting_index = 12



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "await"

func get_shortcode_parameters() -> Dictionary:
	return {
		"character_name" : {"property": "character_name", "default": ""},
		"hide_text" : {"property": "hide_textbox", "default": true},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('character_name', ValueType.SINGLELINE_TEXT, {'left_text':'Wait for', 'right_text':'to finish an action'})
	add_body_edit('hide_textbox', ValueType.BOOL, {'left_text':'Hide text box:'})

#endregion
