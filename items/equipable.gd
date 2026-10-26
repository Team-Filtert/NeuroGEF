class_name ItemEquipable
extends Item

## Equipment (weapon / armor / artifact). While equipped, its modifiers are added
## on top of the member's base stats (see [method Combatant.get_attack] and
## friends). One [enum Slot] enum keeps this one file instead of one per slot.

enum Slot { WEAPON, ARMOR, ARTIFACT }

@export var slot: Slot = Slot.WEAPON

@export_group("Modifiers")
@export var max_health_modifier: int = 0
@export var max_mana_modifier: int = 0
@export var attack_modifier: int = 0
@export var magic_modifier: int = 0
@export var defense_modifier: int = 0
@export var speed_modifier: int = 0
@export var accuracy_modifier: int = 0
