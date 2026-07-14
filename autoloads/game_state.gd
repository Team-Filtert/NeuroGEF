extends Node

var party: Party
var inventory: Inventory

var keys: Dictionary

func add_key(key: String, value = true):
	keys[key] = value

func remove_key(key: String):
	if keys.has(key):
		keys[key] = null

func has_key(key: String) -> bool:
	return keys.has(key)

func get_key(key: String) -> bool:
	return keys[key]

func get_keys() -> Dictionary:
	return keys
