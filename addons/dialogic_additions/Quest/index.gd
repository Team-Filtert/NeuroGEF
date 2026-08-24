@tool
extends DialogicIndexer


func _get_events() -> Array:
	return [
		this_folder.path_join('event_quest.gd'),
		this_folder.path_join('event_if_quest.gd'),
	]


func _get_subsystems() -> Array[Dictionary]:
	return [{'name': 'Quests', 'script': this_folder.path_join('subsystem_quests.gd')}]
