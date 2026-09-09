class_name AddQuest
extends ActionLeaf

@export var quest: Quest

func tick(actor: Node, blackboard: Blackboard) -> int:
	# quests = blackboard.get("quests")
	GameState.quests.add_quest(quest)
	print("Quest added: ", quest)
	print(GameState.quests.get_quests())
	return SUCCESS
