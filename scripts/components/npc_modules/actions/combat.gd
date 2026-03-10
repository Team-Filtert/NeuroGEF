class_name NpcActionCombat
extends NpcActionBase

@export var enemy_file_names: Array[String]

func _preform_action():
	var enemies: Array[CombatantData] = []
	enemies.append(load("res://resources/combatants/" + enemy_file_names[0]))
	if enemy_file_names.size() > 1:
		enemies.append(load("res://resources/combatants/" + enemy_file_names[1]))
		if enemy_file_names.size() > 2:
			enemies.append(load("res://resources/combatants/" + enemy_file_names[2]))
	CombatManager.start_combat(enemies)
