class_name TimingGrade
extends RefCounted

## Result of a timing challenge, shared by both modes.
##
## Grade order matters: PERFECT is best. Tune damage and colors here and
## everything that shows a grade (the QTE bar, the popup) picks it up.

enum Grade { FAIL, BAD, OK, GOOD, SUPER, PERFECT }

const MULTIPLIERS := {
	Grade.FAIL: 0.0,
	Grade.BAD: 0.5,
	Grade.OK: 0.8,
	Grade.GOOD: 1.0,
	Grade.SUPER: 1.25,
	Grade.PERFECT: 1.6,
}

## One color per grade, so the QTE bar can show the score as you aim.
const COLORS := {
	Grade.FAIL: Color(1.0, 0.25, 0.25),
	Grade.BAD: Color(1.0, 0.55, 0.15),
	Grade.OK: Color(1.0, 0.9, 0.25),
	Grade.GOOD: Color(0.5, 1.0, 0.4),
	Grade.SUPER: Color(0.4, 0.85, 1.0),
	Grade.PERFECT: Color(1.0, 0.5, 1.0),
}


static func multiplier(grade: int) -> float:
	return MULTIPLIERS.get(grade, 1.0)


static func color(grade: int) -> Color:
	return COLORS.get(grade, Color.WHITE)


static func label(grade: int) -> String:
	return Grade.keys()[grade]
