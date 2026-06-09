@tool
extends DialogicEvent
class_name DialogicAddPartyMemberEvent

# Define properties of the event here
var combatant: String = ""

func _execute() -> void:
	# This will execute when the event is reached
	var loaded_combatant: CombatantData = load(combatant)
	PartyManager.combat_party.append(loaded_combatant)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Add Party Member"
	event_description = "Add a character to the party"
	event_category = "Main"
	event_sorting_index = 7



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "add_party_member"

func get_shortcode_parameters() -> Dictionary:
	return {
		"combatant" : {"property": "combatant", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('combatant', ValueType.FILE, {'left_text':'Add the combatant', 'right_text':'to the party'})

#endregion
