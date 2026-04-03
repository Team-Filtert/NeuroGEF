class_name NpcActionCombat
extends NpcActionBase

@export var enemy_combatants: Array[CombatantData]

func _preform_action():
	GameManager.combat_manager.start_combat(enemy_combatants)
