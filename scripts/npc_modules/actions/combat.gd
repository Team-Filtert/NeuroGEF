class_name NpcActionCombat
extends NpcActionBase

@export var enemy_combatant1: CombatantData
@export var enemy_combatant2: CombatantData
@export var enemy_combatant3: CombatantData
@export var music: AudioStream

func _preform_action():
	var enemy_combatants: Array[CombatantData] = []
	if enemy_combatant1 != null:
		enemy_combatants.append(enemy_combatant1)
	if enemy_combatant2 != null:
		enemy_combatants.append(enemy_combatant2)
	if enemy_combatant3 != null:
		enemy_combatants.append(enemy_combatant3)
	EventBus.combat_triggered.emit(enemy_combatants, music)
