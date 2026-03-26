extends Node

func save(save_slot: int) -> void:
	var save_file := FileAccess.open("user://save_slot_%d.json" % save_slot, FileAccess.WRITE)
	var save_data := {
		"globals": {
			"party": {
				"combat": [],
				"overworld": []
			},
			"inventory": {
				"wepons": [],
				"armors": [],
				"collectables": [],
				"consumables": []
			}
		},
		"current_scene": {
			"level": $/root/Root/CurrentScene.get_child(0).scene_file_path
		},
		"party_container": {
			"pos_x": $/root/Root/PartyContainer/Player.position.x,
			"pos_y": $/root/Root/PartyContainer/Player.position.y,
		}
	}
	
	for pm in PartyManager.combat_party:
		save_data["globals"]["party"]["combat"].append({
			"path": pm.resource_path,
			"display_name": pm.display_name,
			"texture_path": pm.texture.resource_path,
			"max_health": pm.max_health,
			"health": pm.health,
			"base_attack": pm.base_attack,
			"base_speed": pm.base_speed,
			"base_defense": pm.base_defense
		})
		
	for pm in PartyManager.overworld_party:
		save_data["globals"]["party"]["overworld"].append(pm.scene_file_path)
	
	for stack in Inventory.weapons:
		save_data["globals"]["inventory"]["wepons"].append({
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"max_health_modifier": stack.item.max_health_modifier,
			"attack_modifier": stack.item.attack_modifier,
			"speed_modifier": stack.item.speed_modifier,
			"defense_modifier": stack.item.defense_modifier,
			"amount": stack.amount
		})
	
	for stack in Inventory.armors:
		save_data["globals"]["inventory"]["armors"].append({
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"max_health_modifier": stack.item.max_health_modifier,
			"attack_modifier": stack.item.attack_modifier,
			"speed_modifier": stack.item.speed_modifier,
			"defense_modifier": stack.item.defense_modifier,
			"amount": stack.amount
		})
	
	for stack in Inventory.collectables:
		save_data["globals"]["inventory"]["collectables"].append({
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"amount": stack.amount
		})
	
	for stack in Inventory.consumables:
		save_data["globals"]["inventory"]["consumables"].append({
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"amount": stack.amount
		})
	
	var json_string := JSON.stringify(save_data, "\t")
	save_file.store_string(json_string)
	save_file.close()

func load(save_slot: int) -> void:
	var path := "user://save_slot_%d.json" % save_slot
	if FileAccess.file_exists(path):
		var save_file := FileAccess.open(path, FileAccess.READ)
		var json_string := save_file.get_as_text()
		var json := JSON.new()
		json.parse(json_string)
		var save_data: Dictionary = json.data
		save_file.close()
		
		var current_scene := $/root/Root/CurrentScene
		current_scene.get_child(0).queue_free()
		var level =  load(save_data["current_scene"]["level"]).instantiate()
		current_scene.add_child(level)
		
		var party_container := $/root/Root/PartyContainer
		var party_container_paths: Dictionary = save_data["party_container"]
		var pos := Vector2(party_container_paths["pos_x"], party_container_paths["pos_y"])
		var overworld_party = save_data["globals"]["party"]["overworld"]
		PartyManager.overworld_party = []
		for i in range(party_container.get_child_count()):
			party_container.get_child(i).queue_free()
		for pm in overworld_party:
			var party_member = load(pm).instantiate()
			party_container.add_child(party_member)
			PartyManager.overworld_party.append(party_member)
			party_member.position = pos
		
		var combat_party = save_data["globals"]["party"]["combat"]
		PartyManager.combat_party = []
		for pm in combat_party:
			var party_member: CombatantData = load(pm["path"])
			PartyManager.combat_party.append(party_member)
			party_member.display_name = pm["display_name"]
			party_member.texture = load(pm["texture_path"])
			party_member.max_health = pm["max_health"]
			party_member.health = pm["health"]
			party_member.base_attack = pm["base_attack"]
			party_member.base_speed = pm["base_speed"]
			party_member.base_defense = pm["base_defense"]
		
		Inventory.weapons = []
		for stack in save_data["globals"]["inventory"]["wepons"]:
			var weapon := ItemWepon.new()
			weapon.display_name = stack["display_name"]
			weapon.texture = load(stack["texture_path"])
			weapon.description = stack["description"]
			weapon.max_health_modifier = stack["max_health_modifier"]
			weapon.attack_modifier = stack["attack_modifier"]
			weapon.speed_modifier = stack["speed_modifier"]
			weapon.defense_modifier = stack["defense_modifier"]
			var weapon_stack := ItemStack.new()
			Inventory.weapons.append(weapon_stack)
			weapon_stack.item = weapon
			weapon_stack.amount = stack["amount"]
		
		Inventory.armors = []
		for stack in save_data["globals"]["inventory"]["armors"]:
			var armor := ItemArmor.new()
			armor.display_name = stack["display_name"]
			armor.texture = load(stack["texture_path"])
			armor.description = stack["description"]
			armor.max_health_modifier = stack["max_health_modifier"]
			armor.attack_modifier = stack["attack_modifier"]
			armor.speed_modifier = stack["speed_modifier"]
			armor.defense_modifier = stack["defense_modifier"]
			var armor_stack := ItemStack.new()
			Inventory.weapons.append(armor_stack)
			armor_stack.item = armor
			armor_stack.amount = stack["amount"]
		
		Inventory.collectables = []
		for stack in save_data["globals"]["inventory"]["collectables"]:
			var collectable := ItemCollectable.new()
			collectable.display_name = stack["display_name"]
			collectable.texture = load(stack["texture_path"])
			collectable.description = stack["description"]
			var collectable_stack := ItemStack.new()
			Inventory.weapons.append(collectable_stack)
			collectable_stack.item = collectable
			collectable_stack.amount = stack["amount"]
		
		Inventory.consumables = []
		for stack in save_data["globals"]["inventory"]["consumables"]:
			var consumable := ItemConsumable.new()
			consumable.display_name = stack["display_name"]
			consumable.texture = load(stack["texture_path"])
			consumable.description = stack["description"]
			var consumable_stack := ItemStack.new()
			Inventory.weapons.append(consumable_stack)
			consumable_stack.item = consumable
			consumable_stack.amount = stack["amount"]
