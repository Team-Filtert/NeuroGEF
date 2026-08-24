@tool
extends DialogicIndexer


func _get_events() -> Array:
	return [
		this_folder.path_join('event_key.gd'),
		this_folder.path_join('event_if_key.gd'),
	]


func _get_subsystems() -> Array[Dictionary]:
	return [{'name': 'Keys', 'script': this_folder.path_join('subsystem_keys.gd')}]
