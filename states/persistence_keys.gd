class_name PersistenceKeys
extends RefCounted

var _keys: Dictionary

func add(key: String, value = true):
	_keys[key] = value

func remove(key: String):
	if _keys.has(key):
		_keys[key] = null

func has(key: String) -> bool:
	return _keys.has(key)

func value(key: String) -> bool:
	return _keys[key]

func get_all() -> Dictionary:
	return _keys
