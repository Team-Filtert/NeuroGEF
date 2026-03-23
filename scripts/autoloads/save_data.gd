class_name SaveData
extends Resource

@export var combat_party := PartyManager.combat_party
@export var overworld_party_paths: Array[String]

@export var weapons_inventory := Inventory.weapons
@export var armors_inventory := Inventory.armors
@export var collectables_inventory := Inventory.collectables
@export var consumables_inventory := Inventory.consumables

@export var player_pos: Vector2

@export var current_scene_path: String

static func save(save_slot: int) -> void:
	var save_data := SaveData.new()
	for pm in PartyManager.overworld_party:
		save_data.overworld_party_paths.append(pm.scene_file_path)
	var player := PartyManager.overworld_party[0]
	save_data.player_pos = player.position
	var current_scene := player.get_node("/root/Root/CurrentScene")
	save_data.current_scene_path = current_scene.get_child(0).scene_file_path
	
	ResourceSaver.save(save_data, "user://save_slot_%d.tres" % save_slot)

static func load(save_slot: int) -> void:
	var path := "user://save_slot_%d.tres" % save_slot
	if ResourceLoader.exists(path):
		var save_data: SaveData = ResourceLoader.load(path)
		
		PartyManager.combat_party = save_data.combat_party
		Inventory.weapons = save_data.weapons_inventory
		Inventory.armors = save_data.armors_inventory
		Inventory.collectables = save_data.collectables_inventory
		Inventory.consumables = save_data.consumables_inventory
		
		var player := PartyManager.overworld_party[0]
		player.position = save_data.player_pos
		
		var current_scene := player.get_node("/root/Root/CurrentScene")
		current_scene.get_child(0).queue_free()
		var level = load(save_data.current_scene_path).instantiate()
		current_scene.add_child(level)
		
		var party_container = player.get_node("/root/Root/PartyContainer")
		if party_container.get_child_count() > 1:
			for i in range(1, party_container.get_child_count()):
				party_container.get_child(1).queue_free()
		if save_data.overworld_party_paths.size() > 1:
			for i in range(1, save_data.overworld_party_paths.size()):
				var party_member = load(save_data.overworld_party_paths[i]).instantiate()
				party_container.add_child(party_member)
				party_member.position = save_data.player_pos
