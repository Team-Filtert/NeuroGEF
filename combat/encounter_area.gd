class_name EncounterArea
extends Area2D

## Drop this on an Area2D in a level; walking into it starts a battle.
##
## [member victory_key] / [member quest] are applied on victory (see
## [CombatManager]). For tree-driven encounters use the StartCombat leaf instead.

@export var enemies: Array[EnemyData] = []
@export var victory_key: String
@export var quest: Quest
@export var one_shot := true

var _triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered and one_shot:
		return
	if not (body is Player):
		return
	_triggered = true
	CombatManager.start_combat(enemies, victory_key, quest)
