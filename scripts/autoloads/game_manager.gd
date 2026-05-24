extends Node

signal state_changed(new_state: State)

enum State { MAIN_MENU, OVERWORLD, COMBAT, PAUSED }

var state: State = State.MAIN_MENU:
	set(new_state):
		state = new_state
		state_changed.emit(new_state)

func is_in_overworld() -> bool:
	return state == State.OVERWORLD
