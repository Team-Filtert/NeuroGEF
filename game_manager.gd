extends Node
class_name GameManager

@export var inventory: Inventory
@export var party_members: Array[PartyMember]

@export var scene_container: Node2D
@export var combat_manager: CombatManager
@export var dialogue_manager: DialogueManager

func start_combat(enemies: Array[EnemyCharacter] = []):
	combat_manager.start_combat(enemies)
