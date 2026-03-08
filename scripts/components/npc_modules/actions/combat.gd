class_name NpcActionCombat
extends NpcActionBase

func _preform_action():
	CombatManager.start_combat()
