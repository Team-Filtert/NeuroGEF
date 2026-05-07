extends Node

var slot_count = 3

func get_save_slot_path(save_slot: int) -> String:
	return "user://save_slot_%d.json" % save_slot

func get_save_slots_path():
	var result = []
	for i in slot_count:
		result.append(get_save_slot_path(i))
	
	return result

func check_save_file_exists(save_slot: int):
	return FileAccess.file_exists(get_save_slot_path(save_slot))

func save(save_slot: int) -> void:
	if save_slot < 1 or save_slot > slot_count:
		printerr("save_slot is out of bounds")

	var save_data = LoadManager.serialize_state_json()
	
	var json_string := JSON.stringify(save_data, "\t")

	var save_file := FileAccess.open(get_save_slot_path(save_slot), FileAccess.WRITE)
	save_file.store_string(json_string)
	save_file.close()

func load(save_slot: int) -> void:
	var path := get_save_slot_path(save_slot)
	if FileAccess.file_exists(path):
		var save_file := FileAccess.open(path, FileAccess.READ)
		var json_string := save_file.get_as_text()
		var json := JSON.new()
		json.parse(json_string)

		if not json.data:
			printerr(" Could read save file data: error ocurred on line " \
				 + str(json.get_error_line()) \
				 + "\n with wessage:\n     " \
				 + str(json.get_error_message()))
			
			return

		var save_data: Dictionary = json.data
		save_file.close()

		var inventory_dict: Dictionary = save_data["globals"]["inventory"]
		var money_data = inventory_dict.get("money", 0)
		var weapons_data = inventory_dict.get("wepons", [])
		var armors_data = inventory_dict.get("armors", [])
		var collectables_data = inventory_dict.get("collectables", [])
		var consumables_data = inventory_dict.get("consumables", [])

		LoadManager.load_state(
			save_data["current_scene"]["level"],
			save_data["party_container"],
			save_data["globals"]["party"]["overworld"],
			save_data["globals"]["party"]["combat"],
			money_data,
			weapons_data,
			armors_data,
			collectables_data,
			consumables_data
		)

func remove_save_file(save_slot: int):
	var filepath = get_save_slot_path(save_slot)
	DirAccess.remove_absolute(filepath)
