class_name Leveling
extends RefCounted

## XP curve and level-ups. The curve matches the old game: the XP needed to leave
## level N is 5 * 2^N. Growth is flat per level for now (easy to swap for
## per-member growth later).

const GROWTH := {
	"max_health": 4,
	"max_mana": 2,
	"attack": 2,
	"magic": 2,
	"defense": 2,
	"speed": 1,
}

## One extra stat pick per level, Mario & Luigi style. The label drives the UI.
const BONUS_CHOICES := [
	{"stat": "max_health", "label": "HP", "amount": 3},
	{"stat": "max_mana", "label": "MP", "amount": 2},
	{"stat": "attack", "label": "Attack", "amount": 1},
	{"stat": "magic", "label": "Magic", "amount": 1},
	{"stat": "defense", "label": "Defense", "amount": 1},
	{"stat": "speed", "label": "Speed", "amount": 1},
	{"stat": "accuracy", "label": "Accuracy", "amount": 1},
]


static func xp_requirement(level: int) -> int:
	return 5 * int(pow(2, level))


## Spends XP and raises [param member] a level for each threshold reached.
## Returns a dictionary of the total stat gains (empty if no level-up).
static func apply_level_ups(member: PartyMember) -> Dictionary:
	var gains := {}
	var guard := 0
	while member.xp >= xp_requirement(member.level) and guard < 99:
		guard += 1
		member.xp -= xp_requirement(member.level)
		member.level += 1
		for stat in GROWTH:
			member.set(stat, int(member.get(stat)) + GROWTH[stat])
			gains[stat] = int(gains.get(stat, 0)) + GROWTH[stat]
	return gains


## Applies one player-chosen bonus. HP/MP bonuses also top up the current bar
## (but never revive a KO'd member).
static func apply_bonus(member: PartyMember, stat: String, amount: int) -> void:
	member.set(stat, int(member.get(stat)) + amount)
	if stat == "max_health" and member.health > 0:
		member.health = mini(member.health + amount, member.max_health)
	elif stat == "max_mana":
		member.mana = mini(member.mana + amount, member.max_mana)
