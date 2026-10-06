class_name TimingChallenge
extends Node

## Produces a [enum TimingGrade.Grade] for one action, and is the single place
## that decides which feel a battle uses (from [GameSettings]).
##
## Active mode runs the QTE ([code]Active[/code]); relaxed mode rolls from the
## accuracy stat ([code]Relaxed[/code]). To add a mode, add a subclass and a case
## in [method create]. Everything lives in this one file on purpose.

static func create() -> TimingChallenge:
	# Add new modes here.
	return Active.new() if GameSettings.is_active_mode() else Relaxed.new()


## Base behaviour. [param host] is a [Control] the challenge may mount UI into;
## returns a [enum TimingGrade.Grade] (possibly after awaiting).
func run(_host: Control, _source: Combatant, _action: ActionBase) -> int:
	push_error("TimingChallenge.run() must be overridden by a subclass.")
	return TimingGrade.Grade.GOOD


#region ACTIVE — the QTE

class Active extends TimingChallenge:
	const QTE_SCENE := preload("res://combat/qte/qte_bar.tscn")

	func run(host: Control, source: Combatant, _action: ActionBase) -> int:
		var qte: QteBar = QTE_SCENE.instantiate()
		host.add_child(qte)
		qte.setup(source.get_accuracy())
		var grade: int = await qte.play()
		qte.queue_free()
		return grade

#endregion


#region RELAXED — no input, roll from accuracy

class Relaxed extends TimingChallenge:
	## Chance of a PERFECT; rises with accuracy.
	var base_perfect_chance := 0.05
	var accuracy_per_point := 0.01
	## Rolls below this (but not perfect) land on GOOD; the rest on OK.
	var good_roll := 0.9

	func run(_host: Control, source: Combatant, _action: ActionBase) -> int:
		var perfect_chance := clampf(base_perfect_chance + source.get_accuracy() * accuracy_per_point, 0.0, 1.0)
		var roll := randf()
		if roll < perfect_chance:
			return TimingGrade.Grade.PERFECT
		if roll < good_roll:
			return TimingGrade.Grade.GOOD
		return TimingGrade.Grade.OK

#endregion
