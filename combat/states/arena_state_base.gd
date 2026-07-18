class_name ArenaStateBase
extends Node

@export var next_state: ArenaStateBase
@export var first_substate: ArenaSubstateBase

var current_substate: ArenaSubstateBase

@onready var arena: Arena = get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func change_substate(new_substate: ArenaSubstateBase, i: int):
	if current_substate:
		current_substate.exit()
	current_substate = new_substate
	current_substate.enter(i)

func loop_substates(i: int):
	if current_substate:
		current_substate.exit()
	current_substate = first_substate
	current_substate.enter(i + 1)
