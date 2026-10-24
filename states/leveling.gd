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
