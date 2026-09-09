@tool
class_name DialogicQuestEvent
extends DialogicEvent

## Event that hands a quest to the player by adding it to the game's quest manager.
##
## Quests progress through persistence keys, so use the Key event to advance one and the
## If Quest event to react to it.


### Settings

## Path to the Quest resource that should be started.
@export var quest_path := ""


#region EXECUTE
################################################################################

func _execute() -> void:
	var quests: Variant = dialogic.get_subsystem("Quests")
	if quests == null:
		printerr("[Dialogic] The Quest event needs the Quests subsystem, but it is missing.")
		finish()
		return

	if quest_path.is_empty():
		printerr("[Dialogic] A Quest event has no quest selected.")
		finish()
		return

	quests.start_quest(quest_path)
	finish()

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Quest"
	event_description = "Gives the player a quest. Advance it with the Key event and react to it with the If Quest event."
	set_default_color('Color6')
	event_category = "Logic"
	event_sorting_index = 9

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "quest"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name	: property_info
		"quest"		: {"property": "quest_path", "default": ""},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("Start quest")
	add_header_edit('quest_path', ValueType.FILE, {
			'file_filter'	: "*.tres, *.res; Quest Resources",
			'placeholder'	: "Select Quest",
			'editor_icon'	: ["Resource", "EditorIcons"],
			"type"			: "Quest",
		})

#endregion
