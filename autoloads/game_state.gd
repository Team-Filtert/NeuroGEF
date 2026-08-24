extends Node

var party: Party
var inventory: Inventory
var keys: PersistenceKeys = PersistenceKeys.new()
var quests: QuestManager = QuestManager.new()

func _process(delta: float) -> void:
	# print(quests.get_quests())
	# print()
	for quest in quests.get_quests().values():
		print(quest.progress())
