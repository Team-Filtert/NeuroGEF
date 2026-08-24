@tool
extends RefCounted

## Shared helper for the modules that talk to the game (PersistenceKeys and Quest).
##
## The game data lives in an autoload that is registered *after* Dialogic, so nothing in
## here may reference it by class or identifier: that would make the Dialogic autoload
## fail to compile. Everything goes through the scene tree and duck typing instead.


## Project setting that holds the name of the autoload owning `keys` and `quests`.
const SETTING_AUTOLOAD_NAME := "dialogic/game_state_autoload"
const DEFAULT_AUTOLOAD_NAME := "GameState"


## Name of the autoload the game state is expected to live in.
static func get_autoload_name() -> String:
	return ProjectSettings.get_setting(SETTING_AUTOLOAD_NAME, DEFAULT_AUTOLOAD_NAME)


## Returns the game state autoload, or null if the project doesn't have one.
static func get_game_state(tree: SceneTree) -> Node:
	if tree == null:
		return null
	return tree.root.get_node_or_null(NodePath(get_autoload_name()))


## Returns the object held by [param property] on the game state autoload
## (e.g. "keys" or "quests"), or null.
static func get_game_state_object(tree: SceneTree, property: String) -> Object:
	var game_state := get_game_state(tree)
	if game_state == null:
		return null
	return game_state.get(property)
