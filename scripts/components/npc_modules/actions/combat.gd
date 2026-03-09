class_name NpcActionCombat
extends NpcActionBase

@export var enemy_combatants: Array[CombatantData]

func _preform_action():
	CombatManager.start_combat(enemy_combatants)
