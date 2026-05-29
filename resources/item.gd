# !!! ABSTRACT CLASS, DO NOT INSTANTIATE !!!
class_name Item
extends Resource

@export var display_name: String

var quantity := 1

@warning_ignore("unused_parameter")
static func from_dict(data: Dictionary) -> Item:
	push_error("from_dict() must be overriden in child class")
	return null

func to_dict() -> Dictionary:
	push_error("to_dict() must be overriden in child class")
	return {}