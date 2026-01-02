extends Item
class_name HealItem

@export var heal_value: int = 10

func battle_use(_user: Character, target: Character):
    target.stats.get_heal(heal_value)
