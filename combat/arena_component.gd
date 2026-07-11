class_name ArenaComponent
extends Node

#region state machine

@export var first_state: ArenaStateBase
var current_state: ArenaStateBase

func change_state(new_state: ArenaStateBase):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

#endregion

#region combat core

signal battle_ended

func start_battle() -> void:
	change_state(first_state)

func start_over() -> void:
	change_state(first_state)

#endregion

#region combatants management



#endregion
