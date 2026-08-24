extends DialogicSubsystem

## Subsystem that lets timelines read and write the game's persistence keys
## (see `res://states/persistence_keys.gd`).
##
## The keys themselves belong to the game, not to Dialogic: this subsystem forwards to
## `GameState.keys`, so a flag set from a timeline is the same flag a quest goal, a chest
## or a behaviour tree sees. Every method is safe to call even if the game has no key
## storage, so timelines don't crash in a project without one.
##
## From a timeline:[br]
## [codeblock]
## [key name="talked_to_ved"]
## [key name="cats_found" op="add" amount="1"]
##
## [if_key name="cats_found" is=">=" number="3"]
##     Neuro: That's all of them.
##
## VedAI: You found {Dialogic.get_subsystem("Keys").get_value("cats_found")} cats.
## [/codeblock][br]
## [br]
## This subsystem comes from an extension, so `Dialogic.Keys` only exists after
## regenerating subsystem access in Dialogic's settings. `Dialogic.get_subsystem("Keys")`
## always works, and the If Key event avoids the question entirely.

## Emitted when a key changed, no matter who changed it.
## [param old_value] is `null` if the key didn't exist before.
signal key_changed(key: String, new_value: Variant, old_value: Variant)
## Emitted when a key was erased.
signal key_erased(key: String)

const GameStateAccess := preload("res://addons/dialogic_additions/PersistenceKeys/game_state_access.gd")

## The key storage the signals above are currently hooked up to.
var _connected_storage: Object = null
## Only print the "no key storage" error once, so a project without one isn't spammed.
var _warned_about_storage := false


#region STATE
####################################################################################################

func _post_install() -> void:
	# The game state autoload doesn't exist yet while Dialogic is starting up, so the
	# first lookup (which also hooks up the signals) waits until the tree is complete.
	_connect_when_available.call_deferred()


func _connect_when_available() -> void:
	_get_storage(false)

#endregion


#region WRITING
####################################################################################################

## Sets a key to a value. Defaults to `true`, which covers the usual "this happened" flag.
func set_value(key: String, value: Variant = true) -> void:
	var storage := _get_storage()
	if storage == null:
		return
	storage.set_value(key, value)


## Adds [param amount] to a numeric key and returns the new value.
## A missing key counts as 0, so counters don't have to be set up first.
func increment(key: String, amount: Variant = 1) -> Variant:
	var storage := _get_storage()
	if storage == null:
		return 0
	return storage.increment(key, amount)


## Removes a key entirely. Returns `true` if there was something to remove.
func erase(key: String) -> bool:
	var storage := _get_storage()
	if storage == null:
		return false
	return storage.erase(key)

#endregion


#region READING
####################################################################################################

## Returns `true` if the key exists, no matter what its value is.
func has(key: String) -> bool:
	var storage := _get_storage()
	if storage == null:
		return false
	return storage.has(key)


## Returns the value of a key, or [param default] if it doesn't exist.
func get_value(key: String, default: Variant = null) -> Variant:
	var storage := _get_storage()
	if storage == null:
		return default
	return storage.get_value(key, default)


## Returns the value of a key as a bool. Missing keys, `0` and empty strings are `false`.
func is_true(key: String) -> bool:
	var storage := _get_storage()
	if storage == null:
		return false
	return storage.is_true(key)


## Returns the value of a key as a number, or [param default] if it isn't one.
func get_number(key: String, default := 0.0) -> float:
	var storage := _get_storage()
	if storage == null:
		return default
	return storage.get_number(key, default)


## Returns the value of a key as text, or [param default] if it is missing.
func get_string(key: String, default := "") -> String:
	var storage := _get_storage()
	if storage == null:
		return default
	return storage.get_string(key, default)


## Returns `true` if the key exists and holds exactly [param expected].
func equals(key: String, expected: Variant) -> bool:
	var storage := _get_storage()
	if storage == null:
		return false
	return storage.equals(key, expected)


## Returns `true` if the key is a number of at least [param minimum].
## This is the check "collect 5 of something" goals need.
func at_least(key: String, minimum: float) -> bool:
	var storage := _get_storage()
	if storage == null:
		return false
	return storage.at_least(key, minimum)


## Returns a copy of all keys.
func get_all() -> Dictionary:
	var storage := _get_storage()
	if storage == null:
		return {}
	return storage.get_all()


## Returns the names of all keys starting with [param prefix].
func keys_with_prefix(prefix: String) -> Array:
	var storage := _get_storage()
	if storage == null:
		return []
	return storage.keys_with_prefix(prefix)

#endregion


#region HELPERS
####################################################################################################

## Returns the game's key storage, or null. Also makes sure the signals are hooked up,
## which is done here because it is the one place every access goes through.
func _get_storage(warn := true) -> Object:
	var storage := GameStateAccess.get_game_state_object(get_tree(), "keys")

	if storage == null:
		if warn and not _warned_about_storage:
			_warned_about_storage = true
			printerr('[Dialogic] The Keys subsystem needs "', GameStateAccess.get_autoload_name(), '.keys", but it is missing.')
			dialogic.print_debug_moment()
		return null

	if storage != _connected_storage:
		_connect_storage(storage)

	return storage


## Mirrors the storage's signals, so anything inside Dialogic can listen to key changes
## without having to care about autoload order.
func _connect_storage(storage: Object) -> void:
	_connected_storage = storage

	if storage.has_signal("key_changed") and not storage.key_changed.is_connected(_on_key_changed):
		storage.key_changed.connect(_on_key_changed)

	if storage.has_signal("key_erased") and not storage.key_erased.is_connected(_on_key_erased):
		storage.key_erased.connect(_on_key_erased)


func _on_key_changed(key: String, new_value: Variant, old_value: Variant) -> void:
	key_changed.emit(key, new_value, old_value)


func _on_key_erased(key: String) -> void:
	key_erased.emit(key)

#endregion
