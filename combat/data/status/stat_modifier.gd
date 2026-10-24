class_name StatModifier
extends StatusEffect

## A temporary stat change while the effect is active (a buff if [member amount]
## is positive, a debuff if negative). [member stat] is one of: attack, magic,
## defense, speed, accuracy, max_health, max_mana.

@export var stat: StringName = &"attack"
@export var amount: int = 0
