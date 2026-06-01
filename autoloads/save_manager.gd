extends Node

var current_save_slot := -1

func get_save_file(slot: int) -> String:
	return "user://save_%d.json" % slot

func save_file_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_save_file(slot))

func save() -> void:
	if not Game.state:
		return

	var data := Game.state.to_dict()
	var file := FileAccess.open(get_save_file(current_save_slot), FileAccess.WRITE)
	
	file.store_string(JSON.stringify(data, "\t"))

func load_save(slot: int) -> void:
	if not save_file_exists(slot):
		return

	current_save_slot = slot
	
	var file := FileAccess.open(get_save_file(slot), FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())

	Game.state = GameState.from_dict(data)

func new_game(slot: int) -> void:
	current_save_slot = slot
	Game.state = GameState.new()
