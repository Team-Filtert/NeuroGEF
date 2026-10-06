class_name ActionBase
extends Resource

## One thing a combatant can do when its queued action resolves.
##
## Data lives in the [code].tres[/code]; behaviour lives in [method get_value] and
## [method execute]. Adding a new attack is usually just a new resource, and only
## needs a subclass when the damage formula itself differs.

enum Type { ATTACK, HEAL, BLOCK, BUFF }
## Which offensive stat the action scales off. "normal, magic or both" from the
## design notes maps to one DamageType per resource.
enum DamageType { PHYSICAL, MAGIC }
enum TargetSide { ENEMY, ALLY, SELF }

@export var display_name: StringName = &"Action"
@export var type: Type = Type.ATTACK
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var target_side: TargetSide = TargetSide.ENEMY
@export var mana_cost: int = 0
## Multiplier over the actor's attack (or magic) stat.
@export var power: float = 1.0
## Piercing actions ignore the target's defense.
@export var piercing: bool = false
## Whether the action runs a timing challenge (QTE in active, roll in relaxed).
@export var uses_timing: bool = true
## Hits every valid target instead of a single one.
@export var hits_all: bool = false
@export var ai_weights: AIActionWeights

# Runtime, filled in by the arena when the action is queued. Not exported, so the
# same resource can be shared between combatants.
var source: Combatant
var target: Combatant


func is_available(actor: Combatant) -> bool:
	return actor.get_mana() >= mana_cost


## Raw power before the timing grade is applied.
func get_value(actor: Combatant) -> int:
	var stat := actor.get_magic() if damage_type == DamageType.MAGIC else actor.get_attack()
	return int(round(stat * power))


## Applies the action and returns what actually happened (damage dealt or HP
## restored). The arena uses the return value for ult charge and feedback.
func execute(actor: Combatant, victim: Combatant, grade: int) -> int:
	if mana_cost > 0:
		actor.spend_mana(mana_cost)

	var value := int(round(get_value(actor) * TimingGrade.multiplier(grade)))
	match type:
		Type.HEAL:
			return victim.receive_heal(value)
		Type.ATTACK:
			return victim.take_damage(value, piercing)
	return 0
