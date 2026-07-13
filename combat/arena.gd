class_name Arena
extends Node2D

signal battle_ended

@export var first_state: ArenaStateBase
var current_state: ArenaStateBase

func start_battle(enemies: Array[EnemyData]) -> void:
	change_state(first_state)

func change_state(new_state: ArenaStateBase):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
