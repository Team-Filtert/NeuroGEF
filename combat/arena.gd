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
var _acted: Dictionary = {}
var pending_action: ActionBase
var is_boss := false

var party_ult_charge := 0
var boss_ult_charge := 0

var target_indicator: TargetIndicator
var party_slots: Array[Marker2D] = []
var enemy_slots: Array[Marker2D] = []

var _finishing := false
var _pending_level_ups: Array = []
## Damage + healing done by each party combatant (instance id -> amount).
var _xp_contribution: Dictionary = {}

const COMBATANT_SCENE := preload("res://combat/combatant.tscn")
const TARGET_INDICATOR_SCENE := preload("res://combat/ui/target_indicator.tscn")
## MP restored by a successful block/parry, by timing grade.
const DEFENSE_MP_REWARD := {
	TimingGrade.Grade.GOOD: 1,
	TimingGrade.Grade.SUPER: 2,
	TimingGrade.Grade.PERFECT: 4,
}


func _ready() -> void:
	_collect_slots($Party, party_slots)
	_collect_slots($Enemies, enemy_slots)
	target_indicator = TARGET_INDICATOR_SCENE.instantiate()
	add_child(target_indicator)


## Called by [GameState.push]; [param args] is the Array[EnemyData] to fight.
func enter(args: Variant) -> void:
	start_battle(args if args is Array else [])


func start_battle(enemy_data: Array) -> void:
	# Park the overworld player while the battle is up; [method _finish] restores it.
	PlayerManager.set_player_active(false)
	_xp_contribution.clear()
	var members: Array = GameState.party.members if GameState.party != null else []
	party = _spawn(members, party_slots, $Party, true)
	enemies = _spawn(enemy_data, enemy_slots, $Enemies, false)

	reset_turn_state()
	is_boss = enemies.any(_enemy_is_boss)

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
	for combatant in get_alive_party():
		if not _acted.has(combatant.get_instance_id()):
			return combatant
	return null


func submit_action(action: ActionBase) -> void:
	if action != null:
		action_queue.append(action)


func submit_action_player(action: ActionBase) -> void:
	if action == null or action.source == null:
		return
	submit_action(action)
	_acted[action.source.get_instance_id()] = true


func check_player_turn_over() -> bool:
	return get_current_combatant() == null


func reset_turn_state() -> void:
	action_queue.clear()
	_acted.clear()


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

	if action is Combo and not (action as Combo).steps.is_empty():
		await _perform_combo(action as Combo)
	else:
		var grade := TimingGrade.Grade.GOOD
		var defense_grade := -1
		if action.uses_timing:
			if actor.is_player_controlled:
				grade = await _resolve_timing(actor, action)
				ui.show_grade(grade)
			elif _is_incoming_attack(action):
				var defender := action.target
				defense_grade = await _resolve_timing(defender, action)
				ui.show_grade(defense_grade)
				_reward_defense(defender, defense_grade)

		await _animate_action(action)
		_apply_action(action, grade, defense_grade)

	_tick_statuses(actor, StatusEffect.Timing.END_OF_TURN)


func _resolve_timing(source: Combatant, action: ActionBase) -> int:
	var challenge := TimingChallenge.create()
	add_child(challenge)
	var grade: int = await challenge.run(ui.timing_host, source, action)
	challenge.queue_free()
	return grade


## Enemy attacks aimed at a party member are defended with the same QTE, using
## the defender's accuracy and mitigation instead of the attacker's damage roll.
func _is_incoming_attack(action: ActionBase) -> bool:
	return (
		action.type == ActionBase.Type.ATTACK
		and action.target != null
		and is_instance_valid(action.target)
		and action.target.is_player_controlled
	)


## A clean block/parry restores MP, scaled by how good the timing was.
func _reward_defense(defender: Combatant, grade: int) -> void:
	var amount := int(DEFENSE_MP_REWARD.get(grade, 0))
	if amount > 0:
		defender.receive_mana(amount)


## Runs one challenge per combo step, animating the named participant and
## applying each hit as it lands. Mana is spent once; the turns were already
## consumed when the action was submitted.
func _perform_combo(combo: Combo) -> void:
	if combo.mana_cost > 0:
		combo.source.spend_mana(combo.mana_cost)

	var target := combo.target
	var hits := 0
	var total_damage := 0

	for i in combo.steps.size():
		var step := combo.steps[i]
		var participant := _find_alive_member(step.actor_name)
		if participant == null:
			continue

		var hint := ""
		if not step.input_hint.is_empty():
			hint = "  (%s)" % step.input_hint
		ui.show_message("%s — %s, hit %d/%d%s" % [
			String(combo.display_name),
			participant.get_display_name(),
			i + 1,
			combo.steps.size(),
			hint,
		])

		var grade := TimingGrade.Grade.GOOD
		if combo.uses_timing:
			grade = await _resolve_timing(participant, combo)
			ui.show_grade(grade)

		if target == null or not is_instance_valid(target) or not target.is_alive():
			target = _first_alive_target(combo)
		if target == null:
			break

		await _animate_combo_hit(participant, target)

		var value := int(round(combo.get_value(participant) * step.power * TimingGrade.multiplier(grade)))
		var victims: Array[Combatant] = []
		if combo.hits_all:
			victims = targets_on_side(combo, participant)
		elif target != null:
			victims.append(target)

		for victim in victims:
			if victim == null or not is_instance_valid(victim) or not victim.is_alive():
				continue
			var dealt := victim.take_damage(value, combo.piercing)
			total_damage += dealt
			change_ult_charge(dealt, not participant.is_player_controlled)
			_record_contribution(participant, dealt)
			hits += 1

		refresh_ui(participant)

	if combo.status != null and target != null and is_instance_valid(target) and target.is_alive():
		target.add_status(combo.status.duplicate(true))

	ui.show_message("%s — %d hit(s), %d damage." % [
		String(combo.display_name), hits, total_damage,
	])


func _animate_combo_hit(participant: Combatant, target: Combatant) -> void:
	if target == null or not is_instance_valid(target):
		return
	await participant.move_to(target.global_position)
	await participant.move_home()


func _first_alive_target(combo: Combo) -> Combatant:
	var candidates := targets_on_side(combo, combo.source)
	return candidates[0] if not candidates.is_empty() else null


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


func _apply_action(action: ActionBase, grade: int, defense_grade := -1) -> void:
	var actor := action.source

	if action is Ultimate:
		change_ult_charge(-action.ult_charge_cost, not actor.is_player_controlled)

	if action.hits_all:
		for victim in targets_on_side(action, actor):
			_execute_on(action, actor, victim, grade, defense_grade)
	elif action.target != null:
		_execute_on(action, actor, action.target, grade, defense_grade)

	# A consumable is spent whether or not it did anything.
	if action is ItemAction and (action as ItemAction).item_id != &"":
		GameState.inventory.remove((action as ItemAction).item_id)


func _execute_on(action: ActionBase, actor: Combatant, victim: Combatant, grade: int, defense_grade := -1) -> void:
	var outcome := action.execute(actor, victim, grade, defense_grade)
	# Attacks charge their own side's ult gauge.
	if action.type == ActionBase.Type.ATTACK:
		change_ult_charge(outcome, not actor.is_player_controlled)
		_record_contribution(actor, outcome)
	elif action.type == ActionBase.Type.HEAL:
		_record_contribution(actor, outcome)


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
	if actor.is_player_controlled:
		result.append_array(_item_actions_for(actor))
	# The menu shows values scaled by the actor, so every offered action knows
	# who would use it.
	for action in result:
		action.source = actor
	return result


## Consumables in the inventory, as usable actions for [param actor].
func _item_actions_for(actor: Combatant) -> Array[ActionBase]:
	var result: Array[ActionBase] = []
	if GameState.inventory == null:
		return result
	for item in GameState.inventory.consumables():
		if item.combat_action == null:
			continue
		var action: ItemAction = item.combat_action.duplicate(true)
		action.item_id = item.id
		action.source = actor
		result.append(action)
	return result


func is_party_ult_full() -> bool:
	return max_party_ult_charge > 0 and party_ult_charge >= max_party_ult_charge


func is_boss_ult_full() -> bool:
	return max_boss_ult_charge > 0 and boss_ult_charge >= max_boss_ult_charge


func _combo_available(combo: Combo) -> bool:
	for required in combo.get_required_names():
		var member := _find_alive_member(required)
		if member == null or _acted.has(member.get_instance_id()):
			return false
	return true


func _find_alive_member(required_name: StringName) -> Combatant:
	var wanted := String(required_name).to_lower()
	for member in get_alive_party():
		if member.get_display_name().to_lower() == wanted:
			return member
	return null

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
		_pending_level_ups = _collect_level_ups()
	CombatManager.finish(victory)
	battle_ended.emit(victory)
	_finish(victory)


func _finish(victory: bool) -> void:
	if _finishing:
		return
	_finishing = true
	ui.clear_action_menu()
	await ui.show_banner("Victory!" if victory else "Defeat...")
	if not _pending_level_ups.is_empty():
		await ui.present_level_ups(_pending_level_ups)
	await ui.wait_for_accept()
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
	_share_xp(reward)


## Gives every party member at least 1 XP, then splits the rest by contribution
## (damage dealt + healing done). If nobody contributed — for example the enemies
## died to status effects — the rest is split evenly.
func _share_xp(reward: int) -> void:
	var members: Array[Combatant] = []
	var total := 0
	for member in party:
		if member.data is PartyMember:
			members.append(member)
			total += int(_xp_contribution.get(member.get_instance_id(), 0))
	if members.is_empty():
		return

	# Participation XP, so support members who healed or blocked still grow.
	for member in members:
		(member.data as PartyMember).xp += 1
	var remaining := maxi(reward - members.size(), 0)
	if remaining <= 0:
		return

	if total <= 0:
		var base := floori(float(remaining) / members.size())
		var extra := remaining % members.size()
		for i in members.size():
			(members[i].data as PartyMember).xp += base + (1 if i < extra else 0)
		return

	var shares: Array = []
	var awarded := 0
	for member in members:
		var contribution := int(_xp_contribution.get(member.get_instance_id(), 0))
		var share := floori(float(remaining * contribution) / total)
		(member.data as PartyMember).xp += share
		awarded += share
		shares.append({"member": member, "contribution": contribution})

	# Integer division drops a few points; the biggest contributors get them.
	shares.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["contribution"]) > int(b["contribution"]))
	for i in remaining - awarded:
		var entry: Dictionary = shares[i]
		(entry["member"].data as PartyMember).xp += 1


func _record_contribution(actor: Combatant, amount: int) -> void:
	if amount <= 0 or not actor.is_player_controlled:
		return
	var id := actor.get_instance_id()
	_xp_contribution[id] = int(_xp_contribution.get(id, 0)) + amount


## Applies level-ups to the party and returns a summary per member that gained one.
func _collect_level_ups() -> Array:
	var result: Array = []
	for member in party:
		if member.data is PartyMember:
			var member_data := member.data as PartyMember
			var before_level := member_data.level
			var gains := Leveling.apply_level_ups(member_data)
			if not gains.is_empty():
				result.append({
					"name": member.get_display_name(),
					"level": member_data.level,
					"levels": member_data.level - before_level,
					"gains": gains,
					"member": member_data,
				})
	return result

#endregion


## The battle is drawn in fixed screen space. [GameState] switches the viewport to
## this state's camera on push and back to the level's camera on pop, while the
## fade transition covers the screen, so the arena does not touch the camera itself.
## Refreshes every combatant's bars and points the actor panel at [param actor]
## when one is given (the action's source), otherwise at whoever acts next.
func refresh_ui(actor: Combatant = null) -> void:
	var all := party.duplicate()
	all.append_array(enemies)
	ui.refresh_all(all)
	var shown := actor
	if shown == null or not is_instance_valid(shown) or not shown.is_player_controlled:
		shown = get_current_combatant()
	if shown != null:
		ui.set_actor(shown)


## A battle is a "boss" battle when any enemy either fields an [Ultimate] or is
## flagged [member EnemyData.is_boss]; that is what reveals the boss ult gauge.
func _enemy_is_boss(enemy: Combatant) -> bool:
	if enemy.has_ult():
		return true
	return enemy.data is EnemyData and (enemy.data as EnemyData).is_boss


func _collect_slots(container: Node, into: Array[Marker2D]) -> void:
	for child in container.get_children():
		if child is Marker2D:
			into.append(child)
