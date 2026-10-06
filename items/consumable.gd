class_name Consumable
extends Item

## Usable item. [member combat_action] is what makes it usable in battle (the
## arena adds it to the action list); [member heal] / [member mana] are applied
## when used outside combat.

@export var heal: int = 0
@export var mana: int = 0
@export var combat_action: ItemAction


## Restores HP/MP on a party member outside combat.
func use_out_of_combat(member: CombatantData) -> void:
	if heal > 0:
		member.health = mini(member.health + heal, member.max_health)
	if mana > 0:
		member.mana = mini(member.mana + mana, member.max_mana)
