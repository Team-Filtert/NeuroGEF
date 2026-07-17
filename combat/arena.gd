class_name Arena
extends Node2D

signal battle_ended

@export var combos: Array[Combo]

@export var first_state: ArenaStateBase
var current_state: ArenaStateBase

var party_data: Array[PartyMember]
var enemy_data: Array[EnemyData]

var party_ult_charge: int
var enemy_ult_charge: int

var party_scenes: Array[Combatant]
var enemy_scenes: Array[Combatant]

var action_que: Array[ActionBase] = []

@onready var party_slots: Array[Marker2D] = $Party.get_children() as Array[Marker2D]
@onready var enemy_slots: Array[Marker2D] = $Enemies.get_children() as Array[Marker2D]

func start_battle(enemies: Array[EnemyData]) -> void:
	party_data = GameState.party.members
	party_ult_charge = GameState.party.ult_charge
	enemy_data = enemies
	enemy_ult_charge = 0
	
	change_state(first_state)

func end_battle() -> void:
	current_state.exit()
	battle_ended.emit()

func change_state(new_state: ArenaStateBase):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
