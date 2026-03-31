extends Node

#region loading



func load_state(
		level_path: String,
		pc_paths: Dictionary,
		members_path: Array,
		combat_party: Array,
		money: int,
		weapon_data: Array,
		armors_data: Array,
		collectables_data: Array,
		consumables_data: Array
	):
	
	load_level(level_path)
	load_party_overworld(pc_paths, members_path)
	load_combat_party(combat_party)
	load_money(money)
	load_weapons(weapon_data)
	load_armors(armors_data)
	load_collectables(collectables_data)
	load_consumables(consumables_data)

func load_level(level_path: String):
	var current_scene := SceneManager.scene_container_node
	if not current_scene.get_child_count() == 0:
		var existing_scene = current_scene.get_child(0)
		if existing_scene:
			existing_scene.name = "old_level"
			existing_scene.queue_free()

	var level =  load(level_path).instantiate()
	current_scene.add_child(level)

func load_party_overworld(pc_paths: Dictionary, members_path: Array):
	var party_container := $/root/Root/PartyContainer
	var party_container_paths: Dictionary = pc_paths
	var pos := Vector2(party_container_paths["pos_x"], party_container_paths["pos_y"])
	var overworld_party = members_path
	PartyManager.overworld_party = []
	for i in range(party_container.get_child_count()):
		party_container.get_child(i).name = str(i)
		party_container.get_child(i).queue_free()
	for pm in overworld_party:
		var party_member = load(pm).instantiate()
		party_container.add_child(party_member)
		PartyManager.overworld_party.append(party_member)
		party_member.position = pos

func load_combat_party(combat_party: Array):
	PartyManager.combat_party = []
	for pm in combat_party:
		var party_member: CombatantData = load(pm["path"])
		PartyManager.combat_party.append(party_member)
		party_member.display_name = pm["display_name"]
		party_member.texture = load(pm["texture_path"])
		party_member.max_health = pm["max_health"]
		party_member.health = pm["health"]
		party_member.max_mana = pm["max_mana"]
		party_member.mana = pm["mana"]
		party_member.base_attack = pm["base_attack"]
		party_member.base_speed = pm["base_speed"]
		party_member.base_defense = pm["base_defense"]

func load_money(money: int):
	Inventory.money = money

func load_weapons(weapon_data: Array):
	Inventory.weapons = []
	for stack in weapon_data:
		var weapon := ItemWepon.new()
		weapon.display_name = stack["display_name"]
		weapon.texture = load(stack["texture_path"])
		weapon.description = stack["description"]
		weapon.max_health_modifier = stack["max_health_modifier"]
		weapon.max_mana_modifier = stack["max_mana_modifier"]
		weapon.attack_modifier = stack["attack_modifier"]
		weapon.speed_modifier = stack["speed_modifier"]
		weapon.defense_modifier = stack["defense_modifier"]
		var weapon_stack := ItemStack.new()
		Inventory.weapons.append(weapon_stack)
		weapon_stack.item = weapon
		weapon_stack.amount = stack["amount"]

func load_armors(armors_data: Array):
	Inventory.armors = []
	for stack in armors_data:
		var armor := ItemArmor.new()
		armor.display_name = stack["display_name"]
		armor.texture = load(stack["texture_path"])
		armor.description = stack["description"]
		armor.max_health_modifier = stack["max_health_modifier"]
		armor.max_mana_modifier = stack["max_mana_modifier"]
		armor.attack_modifier = stack["attack_modifier"]
		armor.speed_modifier = stack["speed_modifier"]
		armor.defense_modifier = stack["defense_modifier"]
		var armor_stack := ItemStack.new()
		Inventory.weapons.append(armor_stack)
		armor_stack.item = armor
		armor_stack.amount = stack["amount"]

func load_collectables(collectables_data: Array):
	Inventory.collectables = []
	for stack in collectables_data:
		var collectable := ItemCollectable.new()
		collectable.display_name = stack["display_name"]
		collectable.texture = load(stack["texture_path"])
		collectable.description = stack["description"]
		var collectable_stack := ItemStack.new()
		Inventory.weapons.append(collectable_stack)
		collectable_stack.item = collectable
		collectable_stack.amount = stack["amount"]

func load_consumables(consumables_data: Array):
	Inventory.consumables = []
	for stack in consumables_data:
		var consumable := ItemConsumable.new()
		consumable.display_name = stack["display_name"]
		consumable.texture = load(stack["texture_path"])
		consumable.description = stack["description"]
		var consumable_stack := ItemStack.new()
		Inventory.weapons.append(consumable_stack)
		consumable_stack.item = consumable
		consumable_stack.amount = stack["amount"]



#endregion



#region exporting



func serialize_state_json() -> Dictionary:
	var serialized_data := {
		"globals": {
			"party": {
				"combat": [],
				"overworld": []
			},
			"inventory": {
				"money": Inventory.money,
				"wepons": [],
				"armors": [],
				"collectables": [],
				"consumables": []
			}
		},
		"current_scene": {
			"level": SceneManager.scene_container_node.get_child(0).scene_file_path
		},
		"party_container": {
			"pos_x": $/root/Root/PartyContainer/Player.position.x,
			"pos_y": $/root/Root/PartyContainer/Player.position.y,
		}
	}

	serialized_data["globals"]["party"]["combat"] = serialize_combat_party_data()
	serialized_data["globals"]["party"]["overworld"] = serialize_overworld_party()
	serialized_data["globals"]["inventory"]["wepons"] = serialize_weapons()
	serialized_data["globals"]["inventory"]["armors"] = serialize_armors()
	serialized_data["globals"]["inventory"]["collectables"] = serialize_collectables()
	serialized_data["globals"]["inventory"]["consumables"] = serialize_consumables()

	return serialized_data

func serialize_combat_party_data() -> Array:
	return PartyManager.combat_party.map(func(pm) -> Dictionary:
		return {
			"path": pm.resource_path,
			"display_name": pm.display_name,
			"texture_path": pm.texture.resource_path,
			"max_health": pm.max_health,
			"health": pm.health,
			"max_mana": pm.max_mana,
			"mana": pm.mana,
			"base_attack": pm.base_attack,
			"base_speed": pm.base_speed,
			"base_defense": pm.base_defense
		})

func serialize_overworld_party() -> Array:
	return PartyManager.overworld_party.map(func(pm) -> String: return pm.scene_file_path)

func serialize_weapons() -> Array:
	return Inventory.weapons.map(func(stack) -> Dictionary:
		return {
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"max_health_modifier": stack.item.max_health_modifier,
			"max_mana_modifier": stack.item.max_mana_modifier,
			"attack_modifier": stack.item.attack_modifier,
			"speed_modifier": stack.item.speed_modifier,
			"defense_modifier": stack.item.defense_modifier,
			"amount": stack.amount
		})

func serialize_armors() -> Array:
	return Inventory.armors.map(func(stack) -> Dictionary:
		return {
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"max_health_modifier": stack.item.max_health_modifier,
			"max_mana_modifier": stack.item.max_mana_modifier,
			"attack_modifier": stack.item.attack_modifier,
			"speed_modifier": stack.item.speed_modifier,
			"defense_modifier": stack.item.defense_modifier,
			"amount": stack.amount
		})

func serialize_collectables() -> Array:
	return Inventory.collectables.map(func(stack) -> Dictionary:
		return {
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"amount": stack.amount
		})

func serialize_consumables() -> Array:
	return Inventory.consumables.map(func(stack) -> Dictionary:
		return {
			"path": stack.item.resource_path,
			"display_name": stack.item.display_name,
			"texture_path": stack.item.texture.resource_path,
			"description": stack.item.description,
			"amount": stack.amount
		})



#endregion
