extends Node

## Entry point for combat.
##
## A battle is a normal state on the [GameState] stack, so the overworld keeps
## rendering underneath while the arena runs on top. The arena pops itself when
## the battle is over and reports the result back through [method finish].
##
## Callers can hand in a [param victory_key] (a persistence key set to true) and a
## [param quest] (started on victory). Applying them here means tree/NPC callers
## don't have to observe the battle result themselves.

const ARENA_SCENE := "res://combat/arena.tscn"

## Result of the most recent battle.
var last_victory := false

var _busy := false
var _victory_key := ""
var _reward_quest: Quest


## Starts a battle against [param enemies] (an [code]Array[EnemyData][/code]).
func start_combat(enemies: Array, victory_key := "", quest: Quest = null) -> void:
	if _busy:
		push_warning("CombatManager: a battle is already running.")
		return
	_busy = true
	_victory_key = victory_key
	_reward_quest = quest
	GameState.push(ARENA_SCENE, enemies)


func is_in_combat() -> bool:
	return _busy


## Called by [Arena] when a battle ends. Applies the victory rewards.
func finish(victory: bool) -> void:
	_busy = false
	last_victory = victory

	if victory:
		if _victory_key != "":
			GameState.keys.set_value(_victory_key, true)
		if _reward_quest != null:
			GameState.quests.add_quest(_reward_quest)

	_victory_key = ""
	_reward_quest = null
