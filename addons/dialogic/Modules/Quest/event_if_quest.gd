@tool
class_name DialogicIfQuestEvent
extends DialogicEvent

## Branch event that only plays the events it contains if a quest is in a given state.
##
## This is the Condition event narrowed down to quests, so the quest can be picked from a
## dropdown instead of written as an expression. For anything more involved (combining
## several checks with `and`/`or`) use the normal Condition event with
## `Dialogic.Quests.is_complete("my_quest")`.


enum Checks {
	COMPLETE, 			## The quest was started and all its goals are done.
	NOT_COMPLETE, 		## The quest isn't done, including when it was never started.
	ACTIVE, 			## The quest was started but isn't done yet.
	STARTED, 			## The player has the quest, done or not.
	NOT_STARTED, 		## The player never got the quest.
	PROGRESS_AT_LEAST, 	## The quest is at least this far along, in percent.
}

const GameRegistry := preload("res://addons/dialogic/Modules/PersistenceKeys/game_registry.gd")

### Settings

## Id of the quest to check.
@export var quest_id := ""
## What to check about the quest (see [enum Checks]).
@export var check := Checks.COMPLETE
## Percentage to compare against for [constant Checks.PROGRESS_AT_LEAST].
@export var progress := 50.0


#region EXECUTE
################################################################################

func _execute() -> void:
	if not _matches():
		dialogic.current_event_idx = get_end_branch_index()

	finish()


func _is_branch_starter() -> bool:
	return true


func _matches() -> bool:
	if not dialogic.has_subsystem("Quests"):
		printerr("[Dialogic] The If Quest event needs the Quests subsystem, but it is missing.")
		return false

	if quest_id.is_empty():
		printerr("[Dialogic] An If Quest event has no quest selected.")
		return false

	var quests := dialogic.Quests
	match check:
		Checks.COMPLETE:
			return quests.is_complete(quest_id)
		Checks.NOT_COMPLETE:
			return not quests.is_complete(quest_id)
		Checks.ACTIVE:
			return quests.is_active(quest_id)
		Checks.STARTED:
			return quests.has_quest(quest_id)
		Checks.NOT_STARTED:
			return not quests.has_quest(quest_id)
		Checks.PROGRESS_AT_LEAST:
			return quests.has_quest(quest_id) and quests.get_progress_percent(quest_id) >= progress

	return false

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "If Quest"
	event_description = "Plays the events it contains only if a quest is in a given state."
	set_default_color('Color3')
	event_category = "Flow"
	event_sorting_index = 3
	can_contain_events = true


func _get_end_branch_control() -> Control:
	return load("res://addons/dialogic/Modules/PersistenceKeys/ui_branch_end.tscn").instantiate()


## Shown on the end branch node in the visual editor.
func get_branch_end_text() -> String:
	if quest_id.is_empty():
		return "IF QUEST"
	return "IF QUEST (" + quest_id + " " + _check_label() + ")"


func _check_label() -> String:
	match check:
		Checks.COMPLETE:
			return "is complete"
		Checks.NOT_COMPLETE:
			return "is not complete"
		Checks.ACTIVE:
			return "is active"
		Checks.STARTED:
			return "was started"
		Checks.NOT_STARTED:
			return "was not started"
		Checks.PROGRESS_AT_LEAST:
			return ">= " + str(progress) + "%"
	return ""

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "if_quest"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name	: property_info
		"quest"		: {"property": "quest_id", "default": ""},
		"is"		: {"property": "check", "default": Checks.COMPLETE,
						"suggestions": func(): return {
							"Complete": {'value': Checks.COMPLETE, 'text_alt': ['complete']},
							"Not complete": {'value': Checks.NOT_COMPLETE, 'text_alt': ['not_complete']},
							"Active": {'value': Checks.ACTIVE, 'text_alt': ['active']},
							"Started": {'value': Checks.STARTED, 'text_alt': ['started']},
							"Not started": {'value': Checks.NOT_STARTED, 'text_alt': ['not_started']},
							"Progress at least": {'value': Checks.PROGRESS_AT_LEAST, 'text_alt': ['progress']},
						}},
		"progress"	: {"property": "progress", "default": 50.0},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("If quest")
	add_header_edit('quest_id', ValueType.DYNAMIC_OPTIONS, {
			'suggestions_func'	: get_quest_suggestions,
			'placeholder'		: "Select Quest",
			'editor_icon'		: ["Resource", "EditorIcons"],
			'tooltip'			: "Quest resources found in the project are listed. You can also type an id.",
		})
	add_header_edit('check', ValueType.FIXED_OPTIONS, {'options': [
			{'label': 'is complete', 'value': Checks.COMPLETE},
			{'label': 'is not complete', 'value': Checks.NOT_COMPLETE},
			{'label': 'is active', 'value': Checks.ACTIVE},
			{'label': 'was started', 'value': Checks.STARTED},
			{'label': 'was not started', 'value': Checks.NOT_STARTED},
			{'label': 'is at least', 'value': Checks.PROGRESS_AT_LEAST},
		]})
	add_header_edit('progress', ValueType.NUMBER, {'right_text': "%"},
			'check == Checks.PROGRESS_AT_LEAST')


## Lists the quests found in the project, and keeps whatever is typed usable.
func get_quest_suggestions(filter: String) -> Dictionary:
	var suggestions := {}

	for quest_id_option: String in GameRegistry.get_quests():
		var quest_name: String = GameRegistry.get_quests()[quest_id_option].get("name", "")
		var label := quest_id_option
		if not quest_name.is_empty() and quest_name != quest_id_option:
			label += "  (" + quest_name + ")"
		suggestions[label] = {'value': quest_id_option, 'editor_icon': ["Resource", "EditorIcons"]}

	if not filter.is_empty() and not filter in suggestions:
		suggestions[filter] = {'value': filter, 'editor_icon': ["Add", "EditorIcons"]}

	return suggestions

#endregion
