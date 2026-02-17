class_name NpcTriggerBase
extends Node

var actions: Array[NpcActionBase]

func connect_actions():
	for node in get_children():
		if node is NpcActionBase:
			actions.append(node)

func trigger_actions():
	for action in actions:
		action._perform_action()
