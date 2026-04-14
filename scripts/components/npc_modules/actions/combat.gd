class_name NpcActionCombat
extends NpcActionBase

@export var enemy_combatant1: CombatantData
@export var enemy_combatant2: CombatantData
@export var enemy_combatant3: CombatantData
@export var music: AudioStream

func _preform_action():
	CombatManager.start_combat([enemy_combatant1, enemy_combatant2, enemy_combatant3], music)
