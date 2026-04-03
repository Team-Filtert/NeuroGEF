@tool
extends DialogicEvent
class_name DialogicCombatEvent

# Define properties of the event here
var enemy_1: String = ""
var enemy_2: String = ""
var enemy_3: String = ""

func _execute() -> void:
	# This will execute when the event is reached
	var enemies: Array[CombatantData] = []
	enemies.append(load(enemy_1))
	if enemy_2 != "":
		enemies.append(load(enemy_2))
		if enemy_3 != "":
			enemies.append(load(enemy_3))
	GameManager.combat_manager.start_combat(enemies)
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Combat"
	event_description = "Starts combat"
	set_default_color('Color4')
	event_category = "Flow"
	event_sorting_index = 9



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "combat"

func get_shortcode_parameters() -> Dictionary:
	return {
		'enemy_1' : {"property": "enemy_1", "default": ""},
		'enemy_2' : {"property": "enemy_1", "default": ""},
		'enemy_3' : {"property": "enemy_1", "default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit("enemy_1", ValueType.FILE, {
		'left_text':'Start combat against',
		'placeholder': "Enemy 1",
		'file_filter':'res://resources/combatants/*.tres',
	})
	add_header_edit("enemy_2", ValueType.FILE, {
		'placeholder': "Enemy 2",
		'file_filter':'res://resources/combatants/*.tres',
	})
	add_header_edit("enemy_3", ValueType.FILE, {
		'placeholder': "Enemy 3",
		'file_filter':'res://resources/combatants/*.tres',
	})
#endregion
