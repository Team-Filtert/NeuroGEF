class_name Leveling
extends RefCounted

## XP curve and level-ups. The curve is gentle: leaving level N needs
## 10 * 1.5^(N-1) XP (10, 15, 23, 34, ...). Growth is flat per level for now
## (easy to swap for per-member growth later).

const XP_BASE := 10
const XP_GROWTH := 1.5

const GROWTH := {
	"max_health": 4,
	"max_mana": 2,
	"attack": 2,
	"magic": 2,
	"defense": 2,
	"speed": 1,
}

## One extra stat pick per level. The player chooses the stat, then stops a
## spinning number to roll its amount (Mario & Luigi style).
const BONUS_CHOICES := [
	{"stat": "max_health", "label": "HP", "min": 2, "max": 5},
	{"stat": "max_mana", "label": "MP", "min": 1, "max": 4},
	{"stat": "attack", "label": "Attack", "min": 1, "max": 3},
	{"stat": "magic", "label": "Magic", "min": 1, "max": 3},
	{"stat": "defense", "label": "Defense", "min": 1, "max": 3},
	{"stat": "speed", "label": "Speed", "min": 1, "max": 2},
	{"stat": "accuracy", "label": "Accuracy", "min": 1, "max": 2},
]


static func xp_requirement(level: int) -> int:
	return int(round(XP_BASE * pow(XP_GROWTH, level - 1)))


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
