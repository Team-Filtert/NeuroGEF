class_name PersistenceKeys
extends RefCounted

## Storage for the game's persistent flags, called "keys".
##
## A key is a name with a value attached to it. Anything that has to be remembered outside
## of a single scene belongs here: story flags, opened chests, counters for collect quests,
## which NPC was already talked to, ...
##
## Values can be of any type. Booleans are the common case, so most methods default to
## `true`, but numbers (see [method increment]) and strings work just as well.
##
## Quest goals read these keys (see [PersistenceGoal]) and Dialogic can read and write them
## through its `Dialogic.Keys` subsystem, so a timeline can advance a quest.


## Emitted whenever a key is set to a different value.
## [param old_value] is `null` if the key didn't exist before.
signal key_changed(key: String, new_value: Variant, old_value: Variant)

## Emitted when a key is erased, either through [method erase] or [method clear].
signal key_erased(key: String)


var _keys: Dictionary[String, Variant] = {}


#region WRITING

## Sets a key to a value. Setting a key to the value it already has does nothing,
## so [signal key_changed] only fires on actual changes.
func set_value(key: String, value: Variant = true) -> void:
	var old_value: Variant = _keys.get(key)
	if _keys.has(key) and old_value == value:
		return

	_keys[key] = value
	key_changed.emit(key, value, old_value)


## Older name for [method set_value], kept so existing callers keep working.
func add(key: String, value: Variant = true) -> void:
	set_value(key, value)


## Adds [param amount] to a numeric key and returns the new value.
## A missing or non numeric key counts as 0, so counters don't have to be set up first.
## Whole numbers stay integers, so they read nicely when shown in dialogue.
func increment(key: String, amount: Variant = 1) -> Variant:
	var current: Variant = get_value(key, 0)
	if not typeof(current) in [TYPE_INT, TYPE_FLOAT]:
		current = 0
	if not typeof(amount) in [TYPE_INT, TYPE_FLOAT]:
		amount = 1

	var new_value: Variant = current + amount
	set_value(key, new_value)
	return new_value


## Removes a key entirely, so [method has] returns `false` for it again.
## Returns `true` if there was something to remove.
func erase(key: String) -> bool:
	if not _keys.erase(key):
		return false

	key_erased.emit(key)
	return true


## Older name for [method erase], kept so existing callers keep working.
func remove(key: String) -> bool:
	return erase(key)


## Removes all keys. Emits [signal key_erased] once per key.
func clear() -> void:
	for key in _keys.keys():
		erase(key)

#endregion


#region READING

## Returns `true` if the key exists, no matter what its value is.
func has(key: String) -> bool:
	return _keys.has(key)


## Returns the value of a key, or [param default] if it doesn't exist.
func get_value(key: String, default: Variant = null) -> Variant:
	return _keys.get(key, default)


## Older name for [method get_value], kept so existing callers keep working.
func value(key: String) -> Variant:
	return _keys.get(key)


## Returns the value of a key as a bool. A missing key is `false`, and so are
## `0` and an empty string, which makes this safe to use on any key.
func is_true(key: String) -> bool:
	if not _keys.has(key):
		return false

	var stored: Variant = _keys[key]
	match typeof(stored):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return stored
		TYPE_INT, TYPE_FLOAT:
			return stored != 0
		TYPE_STRING, TYPE_STRING_NAME:
			return not str(stored).is_empty()

	return true


## Returns the value of a key as a number, or [param default] if it is missing
## or not a number.
func get_number(key: String, default := 0.0) -> float:
	var stored: Variant = _keys.get(key)
	if typeof(stored) in [TYPE_INT, TYPE_FLOAT]:
		return float(stored)
	return default


## Returns the value of a key as text, or [param default] if it is missing.
func get_string(key: String, default := "") -> String:
	if not _keys.has(key):
		return default
	return str(_keys[key])


## Returns `true` if the key exists and holds exactly [param expected].
func equals(key: String, expected: Variant) -> bool:
	return _keys.has(key) and _keys[key] == expected


## Returns `true` if the key is a number of at least [param minimum].
## This is what "collect 5 of something" goals need.
func at_least(key: String, minimum: float) -> bool:
	return get_number(key, -INF) >= minimum

#endregion


#region BULK

## Returns a copy of all keys. It is a copy, so changing it won't skip the signals.
func get_all() -> Dictionary:
	return _keys.duplicate()


## Returns the names of all keys starting with [param prefix].
## Useful if keys are grouped by chapter or area, e.g. `"ch1/"`.
func keys_with_prefix(prefix: String) -> Array[String]:
	var found: Array[String] = []
	for key: String in _keys:
		if key.begins_with(prefix):
			found.append(key)
	return found


## Applies a dictionary of keys, e.g. one that came out of a save file.
## Existing keys that aren't in [param data] are left alone unless [param replace] is `true`.
func load_from_dict(data: Dictionary, replace := true) -> void:
	if replace:
		for key: String in _keys.keys():
			if not data.has(key):
				erase(key)

	for key: Variant in data:
		set_value(str(key), data[key])

#endregion
