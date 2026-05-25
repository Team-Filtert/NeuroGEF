extends Node

var weapons: Array[ItemWepon]:
	get:
		return GameStateHandler.game_state.inventory.weapons
var armors: Array[ItemArmor] = []:
	get:
		return GameStateHandler.game_state.inventory.armors
var artifacts: Array[ItemArtifact] = []:
	get:
		return GameStateHandler.game_state.inventory.artifacts
var collectables: Array[ItemCollectable] = []:
	get:
		return GameStateHandler.game_state.inventory.collectables
var consumables: Array[ItemConsumable] = []:
	get:
		return GameStateHandler.game_state.inventory.consumables

var money := 0:
	get:
		return GameStateHandler.game_state.inventory.money

func perform_transaction(
	item: Item = null,
	item_type: Inventory.ItemType = Inventory.ItemType.NONE,
	money_amount: int = 0
	) -> void:
	
	GameStateHandler.game_state.inventory.perform_transaction(item, item_type, money_amount)
