extends Node
class_name GameManager

@export var inventory: Inventory
@export var party_members: Array[PartyMember]

@export var scene_container: Node2D
@export var combat_manager: CombatManager

func start_combat(enemies: Array[EnemyCharacter] = []):
	get_tree().paused = true
	scene_container.visible = false
	combat_manager.visible = true
	combat_manager.init(enemies)
