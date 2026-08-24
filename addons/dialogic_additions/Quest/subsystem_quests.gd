extends DialogicSubsystem

## Subsystem that connects Dialogic to the game's quest system (see `res://states/quests`).
##
## The quest data itself lives outside of Dialogic: the `GameState` autoload owns a
## [code]QuestManager[/code] ([code]GameState.quests[/code]). This subsystem is only a
## bridge, so quests started from a timeline are the same quests the rest of the game sees.
##
## Quest progress comes from persistence keys, so this subsystem watches the Keys subsystem
## and re-checks every quest whenever a key changes, no matter whether the change came from
## a timeline, a chest or a behaviour tree.
##
## From a timeline you can use it like this:[br]
## [codeblock]
## [quest quest="res://data/quests/find_cat.tres"]
## [key name="talked_to_ved"]
##
## [if_quest quest="find_cat" is="complete"]
##     Neuro: Found it!
## [/codeblock][br]
## [br]
## This subsystem comes from an extension, so `Dialogic.Quests` only exists after
## regenerating subsystem access in Dialogic's settings. `Dialogic.get_subsystem("Quests")`
## always works, and the If Quest event avoids the question entirely.

## Emitted when a quest was added to the quest manager through this subsystem.
signal quest_started(quest_id: String)
## Emitted the first time a quest is seen as completed.
signal quest_completed(quest_id: String)

const GameStateAccess := preload("res://addons/dialogic_additions/PersistenceKeys/game_state_access.gd")

## Ids of the quests that [signal quest_completed] was already emitted for.
var _reported_complete := {}
## Only print the "no quest manager" error once, so a project without quests isn't spammed.
var _warned_about_manager := false


#region STATE
####################################################################################################

func _post_install() -> void:
	# Quest goals read persistence keys, so a key change can complete a quest.
	# The Keys subsystem already deals with the game autoload not existing yet.
	var keys := _keys()
	if keys == null:
		return

	keys.key_changed.connect(_on_key_changed)
	keys.key_erased.connect(_on_key_erased)


func _clear_state(clear_flag := DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void:
	if clear_flag & DialogicGameHandler.ClearFlags.TIMELINE_INFO_ONLY:
		return

	# The quests themselves are owned by the game, not by Dialogic, so nothing is reset here.
	# Only the "already announced" bookkeeping is rebuilt, without emitting anything.
	_reported_complete.clear()
	_scan_for_completions(false)

#endregion


#region QUESTS
####################################################################################################

## Adds a quest to the game's quest manager.
## [param quest] can be a Quest resource or a path to one.
## Returns `true` if the quest is in the manager afterwards.
func start_quest(quest: Variant) -> bool:
	var quest_resource: Resource = _resolve_quest(quest)
	if quest_resource == null:
		return false

	var manager := _get_quest_manager()
	if manager == null:
		return false

	var quest_id: String = str(quest_resource.get("id"))
	if quest_id.is_empty():
		printerr('[Dialogic] Quest "', quest_resource.resource_path, '" has no id and cannot be started.')
		return false

	if manager.get_quest(quest_id) != null:
		return true

	manager.add_quest(quest_resource)
	quest_started.emit(quest_id)
	_scan_for_completions()
	return true


## Returns `true` if the quest with the given [param quest_id] was started.
func has_quest(quest_id: String) -> bool:
	return get_quest(quest_id) != null


## Returns the Quest resource with the given [param quest_id], or null if it wasn't started.
func get_quest(quest_id: String) -> Resource:
	var manager := _get_quest_manager()
	if manager == null:
		return null
	return manager.get_quest(quest_id)


## Returns `true` if the quest with the given [param quest_id] is started AND completed.
func is_complete(quest_id: String) -> bool:
	return _is_quest_complete(get_quest(quest_id))


## Returns `true` if the quest was started but isn't completed yet.
func is_active(quest_id: String) -> bool:
	var quest := get_quest(quest_id)
	return quest != null and not _is_quest_complete(quest)


## Returns the progress of a quest as a value between 0.0 and 1.0.
## An unknown quest counts as no progress.
func get_progress(quest_id: String) -> float:
	return _get_quest_progress(get_quest(quest_id))


## Same as [method get_progress] but as a whole percentage, which is nicer to show in text.
func get_progress_percent(quest_id: String) -> int:
	return roundi(get_progress(quest_id) * 100.0)


## Returns the ids of all started quests.
func get_quest_ids() -> Array:
	var manager := _get_quest_manager()
	if manager == null:
		return []
	return manager.get_quests().keys()


## Returns the ids of all started quests that aren't completed yet.
func get_active_quest_ids() -> Array:
	return get_quest_ids().filter(is_active)


## Returns the ids of all completed quests.
func get_completed_quest_ids() -> Array:
	return get_quest_ids().filter(is_complete)


## Re-checks all quests and emits [signal quest_completed] for newly completed ones.
## This happens automatically on every key change, so it is only needed if a quest was
## changed in some other way.
func refresh() -> void:
	_scan_for_completions()

#endregion


#region PERSISTENCE KEYS
####################################################################################################
## Convenience forwarders, so quest code doesn't have to switch between two subsystems.
## The keys live in the Keys subsystem, which is where the full API is.

## Sets a persistence key. Goals of type [code]PersistenceGoal[/code] read these,
## so this is how a timeline advances a quest.
func set_key(key: String, value: Variant = true) -> void:
	var keys := _keys()
	if keys == null:
		return
	keys.set_value(key, value)


## Returns `true` if the persistence key was ever set.
func has_key(key: String) -> bool:
	var keys := _keys()
	if keys == null:
		return false
	return keys.has(key)


## Returns the value of a persistence key, or [param default] if it was never set.
func get_key(key: String, default: Variant = false) -> Variant:
	var keys := _keys()
	if keys == null:
		return default
	return keys.get_value(key, default)

#endregion


#region HELPERS
####################################################################################################

## The Keys subsystem. Subsystems that come from an extension have no typed accessor on
## the Dialogic autoload unless subsystem access is regenerated, so it is looked up by
## name. Returns null if the PersistenceKeys extension isn't installed.
func _keys() -> Variant:
	if not dialogic.has_subsystem("Keys"):
		return null
	return dialogic.get_subsystem("Keys")


func _on_key_changed(_key: String, _new_value: Variant, _old_value: Variant) -> void:
	_scan_for_completions()


func _on_key_erased(_key: String) -> void:
	_scan_for_completions()


## Returns the game's quest manager, or null if the project doesn't have one.
func _get_quest_manager(warn := true) -> Object:
	var manager := GameStateAccess.get_game_state_object(get_tree(), "quests")

	if manager == null and warn and not _warned_about_manager:
		_warned_about_manager = true
		printerr('[Dialogic] The Quests subsystem needs "', GameStateAccess.get_autoload_name(), '.quests", but it is missing.')
		dialogic.print_debug_moment()

	return manager


## Turns a path or a resource into a Quest resource.
func _resolve_quest(quest: Variant) -> Resource:
	if quest is Resource:
		return quest

	var path := str(quest)
	if path.is_empty():
		return null

	if not ResourceLoader.exists(path):
		printerr('[Dialogic] Quest resource "', path, '" does not exist.')
		dialogic.print_debug_moment()
		return null

	var resource: Resource = load(path)
	if resource == null or not ("id" in resource):
		printerr('[Dialogic] "', path, '" is not a Quest resource.')
		dialogic.print_debug_moment()
		return null

	return resource


## The Quest resource forwards to `root.is_complete()`, but the goal classes implement
## `is_completed()`, so the root is asked directly and the quest is only a fallback.
func _is_quest_complete(quest: Resource) -> bool:
	if quest == null:
		return false

	var root: Variant = quest.get("root")
	if root != null and root.has_method("is_completed"):
		return root.is_completed()

	if quest.has_method("is_complete"):
		return quest.is_complete()

	return false


## Same idea as [method _is_quest_complete]: the goals implement `progress()`, the
## QuestNode base class declares `get_progress()`, so both are accepted.
func _get_quest_progress(quest: Resource) -> float:
	if quest == null:
		return 0.0

	if _is_quest_complete(quest):
		return 1.0

	var root: Variant = quest.get("root")
	if root == null:
		return 0.0

	var progress := 0.0
	if root.has_method("progress"):
		progress = float(root.progress())
	elif root.has_method("get_progress"):
		progress = float(root.get_progress())

	return clampf(progress, 0.0, 1.0)


## Checks all quests for completion. Emits [signal quest_completed] for every quest that
## became complete since the last check (unless [param emit] is `false`, which only
## rebuilds the bookkeeping).
func _scan_for_completions(emit := true) -> void:
	var manager := _get_quest_manager(false)
	if manager == null:
		return

	for quest_id: String in manager.get_quests().keys():
		if not _is_quest_complete(manager.get_quest(quest_id)):
			_reported_complete.erase(quest_id)
			continue

		if _reported_complete.has(quest_id):
			continue

		_reported_complete[quest_id] = true
		if emit:
			quest_completed.emit(quest_id)

#endregion
