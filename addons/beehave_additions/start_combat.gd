class_name StartCombat
extends ActionLeaf

## Starts a battle from a behaviour tree. Optional victory rewards (a persistence
## key and/or a quest) are handed to [CombatManager], which applies them when the
## battle ends, so they don't depend on this leaf being ticked at the right time.

@export var enemies: Array[EnemyData] = []
## Persistence key set to true when the battle is won (drives quest goals).
@export var victory_key: String
## Quest started when the battle is won.
@export var quest: Quest

var _started := false


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if CombatManager.is_in_combat():
		return RUNNING
	if _started:
		return SUCCESS
	_started = true
	CombatManager.start_combat(enemies, victory_key, quest)
	return RUNNING
