@tool
extends DialogicEvent
class_name DialogicMoveCameraEvent

enum MethodType {
	BY,
	TO,
}

# Define properties of the event here
var method := MethodType.BY
var vect := Vector2.ZERO
var secs := 1.0

func _execute() -> void:
	# This will execute when the event is reached
	match method:
		MethodType.BY:
			CutsceneManager.move_cam_by(vect, secs)
		MethodType.TO:
			CutsceneManager.move_cam_to(vect, secs)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Move Camera"
	event_description = "Move the camera"
	event_category = "Main"
	event_sorting_index = 2



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "move_camera"

func get_shortcode_parameters() -> Dictionary:
	return {
		"method" : {"property": "method", "default": MethodType.BY},
		"vect" : {"property": "vect", "default": Vector2.ZERO},
		"secs" : {"property": "secs", "default": 1.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('method', ValueType.FIXED_OPTIONS, { 'left_text':'Move the camera',
		'options': [
			{
				'label': 'by',
				'value': MethodType.BY,
			},
			{
				'label': 'to',
				'value': MethodType.TO,
			},
		]
	})
	add_header_edit('vect', ValueType.VECTOR2)
	add_header_edit('secs', ValueType.NUMBER, {'left_text': 'in', 'right_text': 'seconds'})

#endregion
