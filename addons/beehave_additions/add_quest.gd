class_name AddQuest
extends ActionLeaf

@export var quest: Quest

func tick(actor: Node, blackboard: Blackboard) -> int:
	GameState.quests.add_quest(quest)
	return SUCCESS
