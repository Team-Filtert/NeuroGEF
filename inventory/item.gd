extends Resource
class_name Item

@export var item_name: String = "New Item"
@export var item_description: String = "Item Description"
@export var item_icon: Texture2D

func battle_use(_user: Character, _target: Character) -> void:
    pass

func is_valid_target(_cur_char: Character, _target: Character) -> bool:
    return true
