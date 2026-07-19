class_name HideNode
extends ActionLeaf

@export var node: Node

func  tick(actor: Node, blackboard: Blackboard) -> int:
	node.hide()
	(node as TileMapLayer).collision_enabled = false 
	return SUCCESS
