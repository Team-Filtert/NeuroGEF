@tool
extends DialogicEvent
class_name DialogicGiveNewActionEvent

# Define properties of the event here
var dispaly_name: String = ""
var action: String = ""

func _execute() -> void:
	# This will execute when the event is reached
	var combatant_index := PartyManager.combat_party.find_custom(is_selcted_combatant.bind())
	var combatant := PartyManager.combat_party[combatant_index]
	var loaded_action: CombatantAction = load(action)
	combatant.attack_actions.append(loaded_action)
	finish() # called to continue with the next event

func is_selcted_combatant(combatant: CombatantData) -> bool:
	return combatant.display_name == dispaly_name

#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Give New Action"
	event_description = "Give a pary member a new combat action"
	event_category = "Main"
	event_sorting_index = 8



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "give_new_action"

func get_shortcode_parameters() -> Dictionary:
	return {
		"dispaly_name" : {"property": "dispaly_name", "default": ""},
		"action" : {"property": "action", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('action', ValueType.FILE, {'left_text':'Give the combat action'})
	add_header_edit('dispaly_name', ValueType.FILE, {'left_text':'to the character'})

#endregion
