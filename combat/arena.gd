class_name Arena
extends Node2D

## The battlefield and turn hub.
##
## A battle is entered through [method enter] (the [GameState] stack calls it with
## the enemy list) and ends by popping itself. The hub owns the combatants, the
## action queue and the ult gauges, and the child states drive the turn loop:
## choose action -> choose target -> queue enemies -> resolve -> end turn.

signal battle_ended(victory: bool)

@export var first_state: ArenaStateBase
@export var max_party_ult_charge: int = 100
@export var max_boss_ult_charge: int = 100

@onready var action_select_state: ArenaStateBase = %ActionSelectState
@onready var target_select_state: ArenaStateBase = %TargetSelectState
@onready var queue_enemy_actions_state: ArenaStateBase = %QueueEnemyActionsState
@onready var action_resolve_state: ArenaStateBase = %ActionResolveState
@onready var end_turn_state: ArenaStateBase = %EndTurnState
@onready var ui: ArenaUI = %UI
@onready var ai: EnemyAI = %AI

var current_state: ArenaStateBase
var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var action_queue: Array[ActionBase] = []
var player_actions_submitted := 0
var pending_action: ActionBase
var is_boss := false

var party_ult_charge := 0
var boss_ult_charge := 0

var target_indicator: TargetIndicator
var party_slots: Array[Marker2D] = []
var enemy_slots: Array[Marker2D] = []

var _finishing := false
var _previous_camera: Camera2D

const COMBATANT_SCENE := preload("res://combat/combatant.tscn")
const TARGET_INDICATOR_SCENE := preload("res://combat/ui/target_indicator.tscn")


func _ready() -> void:
	_collect_slots($Party, party_slots)
	_collect_slots($Enemies, enemy_slots)
	target_indicator = TARGET_INDICATOR_SCENE.instantiate()
	add_child(target_indicator)
	_take_camera()


## Called by [GameState.push]; [param args] is the Array[EnemyData] to fight.
func enter(args: Variant) -> void:
	start_battle(args if args is Array else [])


func start_battle(enemy_data: Array) -> void:
	# Park the overworld player while the battle is up; [method _finish] restores it.
	PlayerManager.set_player_active(false)
	var members: Array = GameState.party.members if GameState.party != null else []
	party = _spawn(members, party_slots, $Party, true)
	enemies = _spawn(enemy_data, enemy_slots, $Enemies, false)

	reset_turn_state()
	is_boss = enemies.any(func(enemy: Combatant) -> bool: return enemy.has_ult())

	party_ult_charge = GameState.party.ult_charge if GameState.party != null else 0
	boss_ult_charge = 0
	ui.setup_ult(max_party_ult_charge, max_boss_ult_charge, is_boss)
	ui.update_ult(party_ult_charge, false)
	ui.update_ult(boss_ult_charge, true)
	refresh_ui()

	if first_state == null:
		push_error("Arena: first_state is not set.")
		return
	change_state(first_state)


#region STATE MACHINE

func change_state(new_state: ArenaStateBase) -> void:
	if new_state == null:
		push_error("Arena: tried to change to a null state.")
		return
	if current_state != null:
		current_state.exit()
	current_state = new_state
	current_state.enter()

#endregion


#region TURN FLOW

func get_current_combatant() -> Combatant:
	var alive := get_alive_party()
	if player_actions_submitted >= alive.size():
		return null
	return alive[player_actions_submitted]


func submit_action(action: ActionBase) -> void:
	if action != null:
		action_queue.append(action)


func submit_action_player(action: ActionBase) -> void:
	submit_action(action)
	player_actions_submitted += 1


func check_player_turn_over() -> bool:
	return player_actions_submitted >= get_alive_party().size()


func reset_turn_state() -> void:
	action_queue.clear()
	player_actions_submitted = 0


func start_over() -> void:
	for combatant in get_all_alive_combatants():
		_tick_statuses(combatant, StatusEffect.Timing.END_OF_ROUND)

	reset_turn_state()
	for combatant in get_all_alive_combatants():
		combatant.set_blocking(false)
	if _finishing:
		return
	var actor := get_current_combatant()
	if actor != null:
		ui.set_actor(actor)

#endregion


#region RESOLUTION

func perform_action(action: ActionBase) -> void:
	var actor := action.source
	_tick_statuses(actor, StatusEffect.Timing.START_OF_TURN)

	var grade := TimingGrade.Grade.GOOD
	if action.uses_timing:
		grade = await _resolve_timing(action)
		ui.show_grade(grade)

	await _animate_action(action)
	_apply_action(action, grade)

	_tick_statuses(actor, StatusEffect.Timing.END_OF_TURN)


func _resolve_timing(action: ActionBase) -> int:
	var challenge := TimingChallenge.create()
	add_child(challenge)
	var grade: int = await challenge.run(ui.timing_host, action.source, action)
	challenge.queue_free()
	return grade


func _animate_action(action: ActionBase) -> void:
	var actor := action.source
	if action.type == ActionBase.Type.ATTACK and action.target != null:
		await actor.move_to(action.target.global_position)
		await actor.move_home()
		return

	var tween := create_tween()
	tween.tween_property(actor, "position", actor.resting_position + Vector2(0, -6), 0.12)
	tween.tween_property(actor, "position", actor.resting_position, 0.12)
	await tween.finished


func _apply_action(action: ActionBase, grade: int) -> void:
	var actor := action.source

	if action is Ultimate:
		change_ult_charge(-action.ult_charge_cost, not actor.is_player_controlled)

	if action.hits_all:
		for victim in targets_on_side(action, actor):
			_execute_on(action, actor, victim, grade)
	elif action.target != null:
		_execute_on(action, actor, action.target, grade)


func _execute_on(action: ActionBase, actor: Combatant, victim: Combatant, grade: int) -> void:
	var outcome := action.execute(actor, victim, grade)
	# Attacks charge their own side's ult gauge.
	if action.type == ActionBase.Type.ATTACK:
		change_ult_charge(outcome, not actor.is_player_controlled)


## Fires every status on [param combatant] whose timing matches, in priority
## order, and expires the ones that run out. Effects with equal priority are
## meant to be order independent (see [StatusEffect]).
func _tick_statuses(combatant: Combatant, timing: int) -> void:
	if combatant == null or not combatant.is_alive():
		return

	var due: Array[StatusEffect] = []
	for effect in combatant.status_effects:
		if effect.timing == timing:
			due.append(effect)

	due.sort_custom(_lower_priority_first)
	for effect in due:
		effect.tick(combatant)
		if effect.duration > 0:
			effect.duration -= 1
		if effect.duration == 0:
			combatant.remove_status(effect)


func _lower_priority_first(a: StatusEffect, b: StatusEffect) -> bool:
	return a.priority < b.priority

#endregion


#region TARGETS

## Single-target candidates for the picker.
func targets_for(action: ActionBase, actor: Combatant) -> Array[Combatant]:
	return targets_on_side(action, actor)


## All valid targets for a side, used for both picking and AoE.
func targets_on_side(action: ActionBase, actor: Combatant) -> Array[Combatant]:
	match action.target_side:
		ActionBase.TargetSide.ALLY:
			return get_alive_party() if actor.is_player_controlled else get_alive_enemies()
		ActionBase.TargetSide.SELF:
			var self_list: Array[Combatant] = [actor]
			return self_list
		_:
			return get_alive_enemies() if actor.is_player_controlled else get_alive_party()


func available_actions_for(actor: Combatant) -> Array[ActionBase]:
	var result: Array[ActionBase] = []
	for action in actor.actions:
		if not action.is_available(actor):
			continue
		if action is Ultimate and not is_party_ult_full():
			continue
		if action is Combo and not _combo_available(action):
			continue
		result.append(action)
	return result


func is_party_ult_full() -> bool:
	return max_party_ult_charge > 0 and party_ult_charge >= max_party_ult_charge


func _combo_available(combo: Combo) -> bool:
	if combo.required_characters_names.is_empty():
		return true
	var names: Array[String] = []
	for member in party:
		names.append(member.get_display_name().to_lower())
	for required in combo.required_characters_names:
		if not names.has(String(required).to_lower()):
			return false
	return true

#endregion


#region COMBATANTS

func get_alive_party() -> Array[Combatant]:
	return _alive(party)


func get_alive_enemies() -> Array[Combatant]:
	return _alive(enemies)


func get_all_alive_combatants() -> Array[Combatant]:
	var all := get_alive_party()
	all.append_array(get_alive_enemies())
	return all


func _alive(combatants: Array[Combatant]) -> Array[Combatant]:
	var result: Array[Combatant] = []
	for combatant in combatants:
		if combatant.is_alive():
			result.append(combatant)
	return result


func _spawn(data_list: Array, slots: Array[Marker2D], parent: Node2D, player_controlled: bool) -> Array[Combatant]:
	var spawned: Array[Combatant] = []
	for i in mini(data_list.size(), slots.size()):
		var combatant: Combatant = COMBATANT_SCENE.instantiate()
		parent.add_child(combatant)
		combatant.setup(data_list[i] as CombatantData, slots[i].position, player_controlled)
		spawned.append(combatant)
	return spawned

#endregion


#region ULT

func change_ult_charge(amount: int, is_boss_side: bool) -> void:
	if amount == 0:
		return
	if is_boss_side:
		boss_ult_charge = clampi(boss_ult_charge + amount, 0, max_boss_ult_charge)
		ui.update_ult(boss_ult_charge, true)
	else:
		party_ult_charge = clampi(party_ult_charge + amount, 0, max_party_ult_charge)
		ui.update_ult(party_ult_charge, false)

#endregion


#region END

func has_battle_ended() -> bool:
	if get_alive_enemies().is_empty():
		end_battle(true)
		return true
	if get_alive_party().is_empty():
		end_battle(false)
		return true
	return false


func end_battle(victory: bool) -> void:
	_save_party_stats()
	if victory:
		_award_xp()
	CombatManager.finish(victory)
	battle_ended.emit(victory)
	_finish(victory)


func _finish(victory: bool) -> void:
	if _finishing:
		return
	_finishing = true
	ui.clear_action_menu()
	await ui.show_banner("Victory!" if victory else "Defeat...")
	await ui.wait_for_accept()
	_restore_camera()
	PlayerManager.set_player_active(true)
	GameState.pop(victory)


func _save_party_stats() -> void:
	for combatant in party:
		if is_instance_valid(combatant):
			combatant.save_to_data()
	if GameState.party != null:
		GameState.party.ult_charge = party_ult_charge


func _award_xp() -> void:
	var reward := 0
	for enemy in enemies:
		if enemy.data is EnemyData:
			reward += (enemy.data as EnemyData).xp_reward
	if reward <= 0:
		return
	for member in party:
		if member.data is PartyMember:
			(member.data as PartyMember).xp += reward

#endregion


## The battle is drawn in fixed screen space, so it uses its own camera and
## restores whatever camera was active before (usually the player's) on exit.
func _take_camera() -> void:
	_previous_camera = get_viewport().get_camera_2d()
	($Camera2D as Camera2D).make_current()


func _restore_camera() -> void:
	if is_instance_valid(_previous_camera):
		_previous_camera.make_current()


func refresh_ui() -> void:
	var all := party.duplicate()
	all.append_array(enemies)
	ui.refresh_all(all)
	var actor := get_current_combatant()
	if actor != null:
		ui.set_actor(actor)


func _collect_slots(container: Node, into: Array[Marker2D]) -> void:
	for child in container.get_children():
		if child is Marker2D:
			into.append(child)
