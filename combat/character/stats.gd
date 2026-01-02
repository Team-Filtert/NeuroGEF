extends Resource
class_name Stat

@export var max_hp: int = 100
@export var max_mp: int = 50
@export var base_attack: int = 20
@export var base_defense: int = 15
@export var base_speed: int = 10

var current_hp: int = max_hp
var current_mp: int = max_mp

func get_attack() -> int:
    return base_attack
func get_defense() -> int:
    return base_defense
func get_speed() -> int:
    return base_speed

func get_health() -> int:
    return current_hp

func get_mana() -> int:
    return current_mp

func set_hp(new_val: int):
    current_hp = clamp(new_val, 0, max_hp)
func get_damage(dam_val: int):
    set_hp(get_health() - dam_val)
func get_heal(dam_val: int):
    set_hp(get_health() + dam_val)

func set_mana(new_val: int):
    current_mp = clamp(new_val, 0, max_mp)
func spend_mana(amount: int):
    set_mana(get_mana() - amount)
