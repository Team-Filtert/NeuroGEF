class_name GameState
extends Resource

class Party extends Resource:
	var combat_party: Array[CombatantData] = []
	var overworld_party: Array[CharacterBase] = []

class PackedAction extends Resource:
	var action: CombatantAction
	var owner: CombatantData

class PackedComboAction extends Resource:
	var action: CombatantComboAction
	var owners: Array[CombatantData]

class ActionStorage extends Resource:
	var actions: Array[PackedAction]
	var combo_actions: Array[PackedComboAction]

var inventory: Inventory = Inventory.new()
var party: Party = Party.new()
var action_storage: ActionStorage = ActionStorage.new()
