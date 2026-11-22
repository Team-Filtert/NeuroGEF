extends Node2D

## Headless test pass over the combat system and its integrations.
##
## Run it with:
##   godot --headless --path . res://tests/combat_tests.tscn
##
## Prints PASS/FAIL per check and a summary, and exits non-zero if anything
## fails (so it can gate CI). Keep this file updated as the system changes.

class TestStatus extends StatusEffect:
	var ticks := 0
	func tick(_target: Combatant) -> void:
		ticks += 1


var _results: Array = []


func _ready() -> void:
	_test_resources()
	_test_timing_grades()
	_test_qte()
	_test_timing_challenge()
	_test_combatant()
	_test_actions()
	_test_serialization()
	await _test_status_effects()
	await _test_combo_and_ult_gating()
	await _test_combo()
	await _test_default_party_combo()
	await _test_full_battle()
	_test_xp_contribution()
	await _test_stack_and_camera()
	_test_manager_rewards()
	await _test_followers()
	_test_equipment()
	_test_inventory()
	await _test_leveling()
	await _test_status_action()
	await _test_item_action_in_combat()
	await _test_boss_ult_gauge()
	await _test_action_menu()
	_report()


func _check(label: String, condition: bool) -> void:
	_results.append(condition)
	print(("PASS  " if condition else "FAIL  ") + label)


func _report() -> void:
	var passed := 0
	for r in _results:
		if r:
			passed += 1
	print("TEST_SUMMARY: ", passed, "/", _results.size(), " passed")
	print("TEST_RESULT: ", "OK" if passed == _results.size() else "FAILED")
	get_tree().quit(0 if passed == _results.size() else 1)


func _new_arena() -> Arena:
	var arena: Arena = (load("res://combat/arena.tscn") as PackedScene).instantiate()
	add_child(arena)
	return arena


func _new_combatant(data: CombatantData, player_controlled := true) -> Combatant:
	var combatant: Combatant = (load("res://combat/combatant.tscn") as PackedScene).instantiate()
	add_child(combatant)
	combatant.setup(data, Vector2.ZERO, player_controlled)
	return combatant


func _bare_member() -> PartyMember:
	var member := PartyMember.new()
	member.display_name = &"Bare"
	member.max_health = 10
	member.max_mana = 5
	member.attack = 3
	member.magic = 3
	member.defense = 1
	member.speed = 4
	member.accuracy = 0
	member.level = 1
	return member


func _equipment_bonus(data: CombatantData, prop: String) -> int:
	var total := 0
	if data.weapon != null:
		total += int(data.weapon.get(prop))
	for armor in data.armors:
		total += int(armor.get(prop))
	for artifact in data.artifacts:
		total += int(artifact.get(prop))
	return total


#region 1. resources

func _test_resources() -> void:
	for path in [
		"res://data/actions/basic_attack.tres",
		"res://data/actions/healing_touch.tres",
		"res://data/actions/overclock.tres",
		"res://data/combatants/neuro.tres",
		"res://data/combatants/nere.tres",
		"res://data/combatants/swarm_drone.tres",
		"res://data/combatants/swarm_spitter.tres",
		"res://data/combatants/swarm_mender.tres",
		"res://data/combatants/swarm_brute.tres",
		"res://data/combatants/swarm_queen.tres",
		"res://data/combatants/evil.tres",
		"res://data/combatants/evil_enemy.tres",
		"res://data/combatants/nere_boss.tres",
		"res://data/actions/fireball.tres",
		"res://data/actions/anvil_smash.tres",
		"res://data/actions/magic_blast.tres",
		"res://data/actions/fire_it_up.tres",
		"res://data/actions/queen_slam.tres",
		"res://data/actions/acid_spit.tres",
		"res://data/actions/brute_slam.tres",
		"res://data/actions/evil_basic_attack.tres",
		"res://data/actions/pipe_attack.tres",
		"res://data/actions/blow_up_the_crowd.tres",
		"res://data/actions/flare.tres",
		"res://data/actions/boom.tres",
		"res://data/actions/nere_ult.tres",
		"res://data/actions/evil_boss_ult.tres",
		"res://data/actions/one_two_punch.tres",
		"res://data/actions/neuro_basic_attack.tres",
		"res://data/actions/drone_strike.tres",
		"res://data/actions/protective_bubble.tres",
		"res://data/actions/colourful_array.tres",
		"res://data/status/burn.tres",
		"res://data/status/regeneration.tres",
		"res://data/status/attack_up.tres",
		"res://data/status/defense_down.tres",
		"res://data/status/beast_mode.tres",
		"res://data/status/defense_up.tres",
		"res://data/status/colourful_array_regen.tres",
		"res://data/items/potion.tres",
		"res://data/items/mana_tonic.tres",
		"res://data/items/training_sword.tres",
		"res://data/items/spark_wand.tres",
		"res://data/items/leather_vest.tres",
		"res://quests/defeat_drones.tres",
	]:
		_check("resource loads: " + path, load(path) != null)

	var evil := load("res://data/combatants/evil.tres") as PartyMember
	_check("evil: loads as a party member", evil != null)
	_check("evil: sheet stats", evil != null and evil.attack == 7 and evil.magic == 9)
	_check("evil: skill kit", evil != null and evil.actions.size() == 8)
	_check("evil: overworld sprite", evil != null and evil.get_overworld_texture() != null and evil.get_overworld_hframes() == 3)

	var neuro_names: Array = (load("res://data/combatants/neuro.tres") as PartyMember).actions.map(func(action: ActionBase) -> StringName: return action.display_name)
	_check("neuro: sheet skills", neuro_names.has(&"Drone Strike") and neuro_names.has(&"Protective Bubble") and neuro_names.has(&"Colourful Array"))

	var evil_boss := load("res://data/combatants/evil_enemy.tres") as EnemyData
	_check("evil boss: sheet stats", evil_boss != null and evil_boss.max_health == 40 and evil_boss.defense == 7 and evil_boss.attack == 6 and evil_boss.magic == 4 and evil_boss.speed == 10)
	_check("evil boss: has an ultimate", evil_boss != null and evil_boss.has_ult())

	var pipe := load("res://data/actions/pipe_attack.tres") as Attack
	_check("evil: pipe lowers defense", pipe != null and pipe.status is StatModifier and (pipe.status as StatModifier).stat == &"defense" and (pipe.status as StatModifier).amount < 0)

	var boom := load("res://data/actions/boom.tres") as Ultimate
	_check("evil: BOOM is a self buff", boom != null and boom.target_side == ActionBase.TargetSide.SELF)

	var demo := (load("res://levels/ch1/other/combat_demo.tscn") as PackedScene).instantiate()
	_check("demo: has seven fights", demo.get_node_or_null("Fight7") != null)
	var fight_seven: Node = demo.get_node("Fight7")
	var nere_data: EnemyData = fight_seven.get("enemies")[0]
	_check("demo: last fight is Nere", nere_data.display_name == &"Nere")
	var fight_one: Node = demo.get_node("Fight1")
	var fight_four: Node = demo.get_node("Fight4")
	_check("demo: encounter sizes vary", fight_one.get("enemies").size() == 2 and fight_four.get("enemies").size() == 5)
	demo.free()

	var arena_scene := (load("res://combat/arena.tscn") as PackedScene).instantiate()
	_check("arena: supports five enemies", arena_scene.get_node("Enemies").get_child_count() == 5)
	arena_scene.free()

#endregion


#region 2. timing grades

func _test_timing_grades() -> void:
	var grades := [
		TimingGrade.Grade.FAIL, TimingGrade.Grade.BAD, TimingGrade.Grade.OK,
		TimingGrade.Grade.GOOD, TimingGrade.Grade.SUPER, TimingGrade.Grade.PERFECT,
	]
	var colors := {}
	for grade in grades:
		colors[TimingGrade.color(grade)] = true
	_check("timing: 6 distinct colors", colors.size() == 6)

	var ascending := true
	var previous := -1.0
	for grade in grades:
		var m := TimingGrade.multiplier(grade)
		if m < previous:
			ascending = false
		previous = m
	_check("timing: multipliers ascend", ascending)
	_check("timing: FAIL multiplier is 0", TimingGrade.multiplier(TimingGrade.Grade.FAIL) == 0.0)
	_check("timing: PERFECT label", TimingGrade.label(TimingGrade.Grade.PERFECT) == "PERFECT")

#endregion


#region 3. QTE bar

func _test_qte() -> void:
	var qte: QteBar = (load("res://combat/qte/qte_bar.tscn") as PackedScene).instantiate()
	add_child(qte)
	_check("qte: has 5 grade sections", qte.get_node("Sections").get_child_count() == 5)
	_check("qte: centre = PERFECT", qte.grade_for(0.5) == TimingGrade.Grade.PERFECT)
	_check("qte: edge = FAIL", qte.grade_for(0.0) == TimingGrade.Grade.FAIL)

	var before := qte.grade_for(0.45)
	qte.setup(100)
	var after := qte.grade_for(0.45)
	_check("qte: accuracy widens bands", after > before)
	qte.queue_free()

#endregion


#region 4. timing challenge selection

func _test_timing_challenge() -> void:
	GameSettings.save_settings.is_qte_in_active_mode = true
	_check("challenge: active mode -> Active", TimingChallenge.create() is TimingChallenge.Active)
	GameSettings.save_settings.is_qte_in_active_mode = false
	var challenge := TimingChallenge.create()
	_check("challenge: relaxed mode -> Relaxed", challenge is TimingChallenge.Relaxed)

#endregion


#region 5. combatant runtime

func _test_combatant() -> void:
	var data := load("res://data/combatants/neuro.tres") as PartyMember
	var c := _new_combatant(data)
	_check("combatant: sprite sheet applied", c.sprite.hframes == data.sprite_hframes and c.sprite.vframes == data.sprite_vframes)
	_check("party member: overworld sprite configured", data.get_overworld_texture() != null and data.get_overworld_hframes() == 3 and data.get_overworld_vframes() == 4)
	_check("combatant: starts at full health", c.get_health() == c.get_max_health())
	_check("combatant: attack stat includes equipment", c.get_attack() == data.attack + _equipment_bonus(data, "attack_modifier"))
	_check("combatant: accuracy stat includes equipment", c.get_accuracy() == data.accuracy + _equipment_bonus(data, "accuracy_modifier"))
	_check("combatant: party shows an XP bar", c.xp_row.visible)
	_check("combatant: XP bar follows the curve", c.xp_bar.max_value == Leveling.xp_requirement(data.level))

	var dealt := c.take_damage(10)
	_check("combatant: damage minus defense", dealt == 10 - c.get_defense())

	var full := c.get_health()
	var dealt_piercing := c.take_damage(10, true)
	_check("combatant: piercing ignores defense", dealt_piercing == 10 and c.get_health() == full - 10)

	c.set_blocking(true)
	var blocked := c.take_damage(10)
	_check("combatant: blocking doubles defense", blocked == 10 - c.get_defense() * 2)
	c.set_blocking(false)

	var healed := c.receive_heal(5)
	_check("combatant: heal works", healed > 0)

	c.spend_mana(3)
	_check("combatant: mana spent", c.get_mana() == c.get_max_mana() - 3)

	c.take_damage(9999)
	_check("combatant: dies at 0 HP", not c.is_alive())
	c.queue_free()

	var enemy := _new_combatant(load("res://data/combatants/swarm_drone.tres") as EnemyData, false)
	_check("combatant: enemies hide the XP bar", not enemy.xp_row.visible)
	enemy.queue_free()

#endregion


#region 6. actions

func _test_actions() -> void:
	var attack := load("res://data/actions/basic_attack.tres") as Attack
	var heal := load("res://data/actions/healing_touch.tres") as Heal
	_check("action: basic attack is Attack", attack is Attack)
	_check("action: healing touch is Heal", heal is Heal)
	_check("action: heal targets allies", heal.target_side == ActionBase.TargetSide.ALLY)
	_check("action: heal costs mana", heal.mana_cost > 0)

	var data := load("res://data/combatants/neuro.tres") as PartyMember
	var actor := _new_combatant(data)
	var victim := _new_combatant(load("res://data/combatants/swarm_drone.tres") as EnemyData, false)

	_check("action: physical value = attack", attack.get_value(actor) == actor.get_attack())
	_check("action: magic value = magic", heal.get_value(actor) == actor.get_magic())

	var hp := victim.get_health()
	var dealt := attack.execute(actor, victim, TimingGrade.Grade.PERFECT)
	_check("action: execute deals damage", dealt > 0 and victim.get_health() < hp)

	actor.take_damage(10)
	var before := actor.get_health()
	heal.execute(actor, actor, TimingGrade.Grade.GOOD)
	_check("action: execute heals", actor.get_health() > before)

	actor.spend_mana(actor.get_max_mana())
	_check("action: unavailable without mana", not heal.is_available(actor))

	actor.queue_free()
	victim.queue_free()

#endregion


#region 7. serialization

func _test_serialization() -> void:
	var member := load("res://data/combatants/neuro.tres") as PartyMember
	var round_tripped := PartyMember.from_dict(member.to_dict())
	_check("save: display_name survives", round_tripped.display_name == member.display_name)
	_check("save: accuracy survives", round_tripped.accuracy == member.accuracy)
	_check("save: stats survive", round_tripped.attack == member.attack and round_tripped.max_health == member.max_health)
	_check("save: level survives", round_tripped.level == member.level)
	_check("save: actions survive", round_tripped.actions.size() == member.actions.size())
	_check("save: overworld sprite survives", round_tripped.overworld_texture != null and round_tripped.overworld_hframes == member.overworld_hframes)
	_check("save: combat sprite layout survives", round_tripped.sprite_hframes == member.sprite_hframes and round_tripped.sprite_frame == member.sprite_frame)

#endregion


#region 8. status effects

func _test_status_effects() -> void:
	var arena := _new_arena()
	var combatant := _new_combatant(load("res://data/combatants/neuro.tres") as PartyMember)

	var status := TestStatus.new()
	status.timing = StatusEffect.Timing.END_OF_TURN
	status.duration = 2
	combatant.add_status(status)

	arena._tick_statuses(combatant, StatusEffect.Timing.START_OF_TURN)
	_check("status: wrong phase does nothing", status.ticks == 0)

	arena._tick_statuses(combatant, StatusEffect.Timing.END_OF_TURN)
	_check("status: ticks on its phase", status.ticks == 1 and status.duration == 1)

	arena._tick_statuses(combatant, StatusEffect.Timing.END_OF_TURN)
	_check("status: expires after duration", status.ticks == 2 and not combatant.status_effects.has(status))

	arena.queue_free()
	combatant.queue_free()
	await get_tree().process_frame

#endregion


#region 9. combo / ult gating

func _test_combo_and_ult_gating() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.add_member(load("res://data/combatants/nere.tres") as PartyMember)

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame

	var neuro := arena.party[0]

	arena.party_ult_charge = 0
	var without_ult := arena.available_actions_for(neuro)
	arena.party_ult_charge = arena.max_party_ult_charge
	var with_ult := arena.available_actions_for(neuro)
	_check("gating: ult hidden when gauge empty", _count_ult(without_ult) == 0)
	_check("gating: ults shown when gauge full", _count_ult(with_ult) == 2)

	var combo := Combo.new()
	combo.display_name = &"Combo"
	combo.required_characters_names = [&"Neuro", &"Nere"]
	neuro.actions.append(combo)
	_check("gating: combo available with party", arena.available_actions_for(neuro).has(combo))
	combo.required_characters_names = [&"Nobody"]
	_check("gating: combo hidden without party", not arena.available_actions_for(neuro).has(combo))

	arena.queue_free()
	await get_tree().process_frame


func _count_ult(actions: Array[ActionBase]) -> int:
	var n := 0
	for action in actions:
		if action is Ultimate:
			n += 1
	return n


func _test_combo() -> void:
	GameSettings.save_settings.is_qte_in_active_mode = false
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.add_member(load("res://data/combatants/nere.tres") as PartyMember)

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame

	var neuro := arena.party[0]
	var combo: Combo = null
	for action in neuro.actions:
		if action is Combo:
			combo = action as Combo
			break

	_check("combo: present on Neuro", combo != null)
	if combo == null:
		arena.queue_free()
		await get_tree().process_frame
		return

	_check("combo: has two steps", combo.steps.size() == 2)
	_check("combo: names both participants", combo.get_required_names().size() == 2)
	_check("combo: offered with party intact", arena.available_actions_for(neuro).has(combo))

	arena.reset_turn_state()
	combo.source = neuro
	combo.target = arena.enemies[0]
	arena.submit_action_player(combo)
	_check("combo: consumes every participant's turn", arena.get_current_combatant() == null)

	var before := arena.enemies[0].get_health()
	await arena.perform_action(combo)
	_check("combo: lands its hits", arena.enemies[0].get_health() < before)

	arena.party[1].take_damage(9999)
	arena.reset_turn_state()
	_check("combo: hidden when a participant is down", not arena.available_actions_for(neuro).has(combo))

	arena.queue_free()
	await get_tree().process_frame

#endregion


#region 9b. default party combo

func _test_default_party_combo() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.add_member(load("res://data/combatants/evil.tres") as PartyMember)

	var arena := _new_arena()
	arena.start_battle([load("res://data/combatants/swarm_drone.tres") as EnemyData] as Array[EnemyData])
	await get_tree().process_frame

	var neuro := arena.party[0]
	var combo: Combo = null
	for action in neuro.actions:
		if action is Combo and action.display_name == &"One-Two Punch":
			combo = action
			break
	_check("combo: default party has one", combo != null)
	if combo != null:
		_check("combo: default party combo is offered", arena.available_actions_for(neuro).has(combo))

	arena.queue_free()
	await get_tree().process_frame

#endregion


#region 10. full battle

func _test_full_battle() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.add_member(load("res://data/combatants/nere.tres") as PartyMember)
	GameState.party.ult_charge = 0

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame

	var rounds := 0
	while rounds < 40 and not arena.get_alive_enemies().is_empty() and not arena.get_alive_party().is_empty():
		rounds += 1
		arena.reset_turn_state()
		for actor in arena.get_alive_party():
			if arena.get_alive_enemies().is_empty():
				break
			var actions := arena.available_actions_for(actor)
			if actions.is_empty():
				continue
			var action: ActionBase = actions[0]
			action.source = actor
			action.target = arena.get_alive_enemies()[0]
			arena.submit_action_player(action)
		for enemy in arena.get_alive_enemies():
			var enemy_action := arena.ai.choose_action(enemy, arena)
			if enemy_action != null:
				arena.submit_action(enemy_action)

		for action in arena.action_queue:
			if action.source == null or not action.source.is_alive():
				continue
			await arena.perform_action(action)
			if arena.has_battle_ended():
				break
		if arena.get_alive_enemies().is_empty() or arena.get_alive_party().is_empty():
			break
		arena.start_over()

	_check("battle: ended within 40 rounds", rounds < 40)
	_check("battle: victory", arena.get_alive_enemies().is_empty() and not arena.get_alive_party().is_empty())
	_check("battle: CombatManager reported victory", CombatManager.last_victory)
	_check("battle: XP awarded to party", (GameState.party.members[0] as PartyMember).xp > 0)
	var saved: PartyMember = GameState.party.members[0]
	_check("battle: party HP saved back to data", saved.health <= saved.max_health + _equipment_bonus(saved, "max_health_modifier"))

	arena.queue_free()
	await get_tree().process_frame

#endregion


#region 10b. xp contribution

func _test_xp_contribution() -> void:
	var arena := _new_arena()
	var first := _bare_member()
	var second := _bare_member()
	var combatant_a := _new_combatant(first)
	var combatant_b := _new_combatant(second)
	arena.party.append(combatant_a)
	arena.party.append(combatant_b)

	var enemy_data := EnemyData.new()
	enemy_data.xp_reward = 20
	var enemy := _new_combatant(enemy_data, false)
	arena.enemies.append(enemy)

	# Damage dealt through the normal resolution path is tracked.
	var attack := load("res://data/actions/basic_attack.tres") as Attack
	arena._execute_on(attack, combatant_a, enemy, TimingGrade.Grade.GOOD)
	_check("xp: damage records contribution", int(arena._xp_contribution.get(combatant_a.get_instance_id(), 0)) > 0)

	arena._xp_contribution.clear()
	arena._xp_contribution[combatant_a.get_instance_id()] = 15
	arena._xp_contribution[combatant_b.get_instance_id()] = 5
	arena._award_xp()
	_check("xp: splits by contribution", first.xp == 15 and second.xp == 5)

	first.xp = 0
	second.xp = 0
	arena._xp_contribution.clear()
	arena._award_xp()
	_check("xp: splits evenly without contributions", first.xp == 10 and second.xp == 10)

	arena.queue_free()
	combatant_a.queue_free()
	combatant_b.queue_free()
	enemy.queue_free()

#endregion


#region 11. stack suspends + camera

func _test_stack_and_camera() -> void:
	GameState.init(self, self)
	var level := Node2D.new()
	add_child(level)
	var cam := Camera2D.new()
	level.add_child(cam)
	cam.make_current()

	# Seed the stack by hand so the "level" behaves like a pushed state.
	GameState.state_stack.clear()
	GameState.state_stack.push_back(level)
	GameState.current_state = level

	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	GameState.push("res://combat/arena.tscn", enemies, false, "")
	await get_tree().process_frame
	var arena: Arena = GameState.current_state

	_check("stack: level hidden during combat", not level.visible)
	_check("stack: level frozen during combat", level.process_mode == Node.PROCESS_MODE_DISABLED)
	_check("stack: arena camera is current", get_viewport().get_camera_2d() == arena.get_node("Camera2D"))

	arena.start_over()
	await GameState.pop(null, "")
	await get_tree().process_frame
	_check("stack: level camera restored after combat", get_viewport().get_camera_2d() == cam)
	_check("stack: level restored after combat", level.visible and level.process_mode == Node.PROCESS_MODE_INHERIT)

	level.queue_free()
	await get_tree().process_frame

#endregion


#region 12. manager rewards

func _test_manager_rewards() -> void:
	GameState.keys.set_value("drones_defeated", false)
	GameState.quests.quests.clear()
	CombatManager.set("_victory_key", "drones_defeated")
	CombatManager.set("_reward_quest", load("res://quests/defeat_drones.tres"))
	CombatManager.finish(true)
	_check("rewards: victory sets key", GameState.keys.is_true("drones_defeated"))
	_check("rewards: victory starts quest", GameState.quests.get_quest("defeat_drones") != null)
	_check("rewards: quest goal completes via key", GameState.quests.is_completed("defeat_drones"))

	GameState.keys.set_value("drones_defeated", false)
	GameState.quests.quests.clear()
	CombatManager.set("_victory_key", "drones_defeated")
	CombatManager.set("_reward_quest", load("res://quests/defeat_drones.tres"))
	CombatManager.finish(false)
	_check("rewards: defeat sets nothing", not GameState.keys.is_true("drones_defeated"))
	_check("rewards: defeat starts no quest", GameState.quests.get_quest("defeat_drones") == null)

#endregion


#region 13. followers

func _test_followers() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.add_member(load("res://data/combatants/nere.tres") as PartyMember)
	PlayerManager.init(self)
	PlayerManager.spawn_player(Vector2(100, 100))
	await get_tree().process_frame
	_check("followers: one per extra member", PlayerManager.follower_count() == 1)

	var player := PlayerManager.get_player()
	var leader := GameState.party.members[0]
	var leader_sprite := player.get_node("Sprite2D") as Sprite2D
	_check("leader: uses party[0] overworld sprite", leader_sprite.texture == leader.get_overworld_texture())
	_check("leader: uses party[0] overworld layout", leader_sprite.hframes == leader.get_overworld_hframes() and leader_sprite.vframes == leader.get_overworld_vframes())
	PlayerManager.set_player_position(Vector2.ZERO)
	for i in 50:
		player.global_position = Vector2(i * 4, 0)
		await get_tree().physics_frame
	var follower: Node2D = player.get_parent().get_child(player.get_index() + 1)
	_check("followers: trail behind the leader", follower.global_position.x < player.global_position.x)

	PlayerManager.set_player_active(false)
	_check("followers: parked with the player", not follower.is_physics_processing())
	PlayerManager.despawn_player()
	await get_tree().process_frame

#endregion


#region 14. equipment

func _test_equipment() -> void:
	var plain := _new_combatant(_bare_member())
	_check("equipment: no gear = base attack", plain.get_attack() == 3)

	var sword := load("res://data/items/training_sword.tres") as ItemEquipable
	var vest := load("res://data/items/leather_vest.tres") as ItemEquipable
	var geared := _bare_member()
	geared.weapon = sword
	geared.armors.append(vest)
	var armed := _new_combatant(geared)
	_check("equipment: weapon raises attack", armed.get_attack() == geared.attack + sword.attack_modifier)
	_check("equipment: armor raises max HP", armed.get_max_health() == geared.max_health + vest.max_health_modifier)
	_check("equipment: armor raises defense", armed.get_defense() == geared.defense + vest.defense_modifier)
	_check("equipment: fresh combatant fills equipment-aware HP", armed.get_health() == armed.get_max_health())

	plain.queue_free()
	armed.queue_free()

#endregion


#region 15. inventory

func _test_inventory() -> void:
	var inv := Inventory.new()
	var potion := load("res://data/items/potion.tres") as Consumable
	_check("inventory: starts empty", inv.items().is_empty())

	inv.add(potion, 2)
	_check("inventory: add stacks", inv.count(potion.id) == 2 and inv.has(potion.id))
	_check("inventory: consumables listed", inv.consumables().has(potion))

	_check("inventory: remove decrements", inv.remove(potion.id) and inv.count(potion.id) == 1)
	inv.remove(potion.id)
	_check("inventory: removing the last drops the id", not inv.has(potion.id))

	inv.add(potion, 3)
	inv.money = 42
	var restored := Inventory.new()
	restored.from_dict(inv.to_dict())
	_check("inventory: serializes money", restored.money == 42)
	_check("inventory: serializes stacks", restored.count(potion.id) == 3)

#endregion


#region 16. leveling

func _test_leveling() -> void:
	_check("leveling: curve starts at 10", Leveling.xp_requirement(1) == 10)
	_check("leveling: curve stays gentle", Leveling.xp_requirement(3) == 23)
	var member := _bare_member()
	member.xp = Leveling.xp_requirement(member.level)
	var before_attack := member.attack
	var gains := Leveling.apply_level_ups(member)
	_check("leveling: reaches level 2", member.level == 2)
	_check("leveling: spends the xp", member.xp == 0)
	_check("leveling: returns the gains", not gains.is_empty())
	_check("leveling: stats rise", member.attack == before_attack + Leveling.GROWTH["attack"])

	var multi := _bare_member()
	multi.xp = Leveling.xp_requirement(1) + Leveling.xp_requirement(2)
	Leveling.apply_level_ups(multi)
	_check("leveling: multiple levels in one pass", multi.level == 3)

	var bonus_target := _bare_member()
	var before_bonus_defense := bonus_target.defense
	Leveling.apply_bonus(bonus_target, "defense", 1)
	_check("leveling: bonus applies", bonus_target.defense == before_bonus_defense + 1)

	# The arena hands its summaries to the panel; check the panel renders them.
	var arena := _new_arena()
	arena.ui.show_level_ups([{"name": "Bare", "level": 2, "gains": {"attack": 2}}])
	var panel: LevelUpPanel = arena.ui.get_node("LevelUpPanel")
	var entries: Label = arena.ui.get_node("LevelUpPanel/Center/Panel/Margin/VBox/Entries")
	_check("leveling: panel shows the member", entries.text.contains("Bare"))
	_check("leveling: panel shows the gains", entries.text.contains("+2 attack"))
	_check("leveling: panel is visible", panel.visible)
	_check("leveling: panel fills the screen", panel.size == arena.ui.size)
	var inner: Control = panel.get_node("Center/Panel")
	_check("leveling: panel fits the viewport", inner.size.x <= arena.ui.size.x and inner.size.y <= arena.ui.size.y)

	var bonus_member := _bare_member()
	arena.ui.show_level_ups([{
		"name": "Bare",
		"level": 2,
		"levels": 1,
		"gains": {"attack": 2},
		"member": bonus_member,
	}])
	var choices: GridContainer = arena.ui.get_node("LevelUpPanel/Center/Panel/Margin/VBox/Choices")
	_check("leveling: bonus choices shown", choices.visible and choices.get_child_count() == Leveling.BONUS_CHOICES.size())
	var defense_button: Button = null
	for child in choices.get_children():
		if (child as Button).text.contains("Defense"):
			defense_button = child
			break
	_check("leveling: defense choice exists", defense_button != null)
	var before_defense := bonus_member.defense
	if defense_button != null:
		defense_button.pressed.emit()

	await get_tree().process_frame
	var roulette: Label = arena.ui.get_node("LevelUpPanel/Center/Panel/Margin/VBox/Roulette")
	var stop: Button = arena.ui.get_node("LevelUpPanel/Center/Panel/Margin/VBox/Stop")
	_check("leveling: roulette shown", roulette.visible and stop.visible)
	_check("leveling: roulette panel fits the viewport", inner.size.y <= arena.ui.size.y)
	var rolled := int(roulette.text)
	_check("leveling: rolled amount in range", rolled >= 1 and rolled <= 3)
	stop.pressed.emit()
	await get_tree().create_timer(0.5).timeout
	_check("leveling: chosen bonus applies", bonus_member.defense == before_defense + rolled)
	_check("leveling: choices finish", not panel.has_choices())
	_check("leveling: summary shows the bonus", entries.text.contains("+%d Defense" % rolled))
	arena.queue_free()

#endregion


#region 17. status actions

func _test_status_action() -> void:
	var burn := load("res://data/status/burn.tres") as DamageOverTime
	_check("status: burn is a DoT", burn is DamageOverTime and burn.damage > 0)

	var fireball := load("res://data/actions/fireball.tres") as Attack
	_check("status: fireball carries burn", fireball.status == burn)

	var arena := _new_arena()
	var actor := _new_combatant(_bare_member())
	var victim := _new_combatant(_bare_member(), false)
	fireball.execute(actor, victim, TimingGrade.Grade.GOOD)
	_check("status: attack applies its status", victim.status_effects.size() == 1 and victim.status_effects[0] is DamageOverTime)

	var hp := victim.get_health()
	arena._tick_statuses(victim, StatusEffect.Timing.END_OF_TURN)
	_check("status: burn damages on its tick", victim.get_health() < hp)

	var buff_action := load("res://data/actions/fire_it_up.tres") as StatusAction
	var buff_target := _new_combatant(_bare_member())
	var before_atk := buff_target.get_attack()
	buff_action.execute(actor, buff_target, TimingGrade.Grade.GOOD)
	_check("status: buff raises the stat", buff_target.get_attack() > before_atk)

	arena.queue_free()
	actor.queue_free()
	victim.queue_free()
	buff_target.queue_free()
	await get_tree().process_frame

#endregion


#region 18. items in combat

func _test_item_action_in_combat() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.ult_charge = 0
	GameState.inventory = Inventory.new()
	GameState.inventory.add(load("res://data/items/potion.tres") as Consumable, 1)

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame

	var neuro := arena.party[0]
	neuro.take_damage(10, true)
	var items := arena.available_actions_for(neuro).filter(func(a: ActionBase) -> bool: return a is ItemAction)
	_check("items: consumable offered in combat", items.size() == 1)
	_check("items: action knows its item id", (items[0] as ItemAction).item_id == &"potion")

	var before := neuro.get_health()
	items[0].source = neuro
	items[0].target = neuro
	arena._apply_action(items[0], TimingGrade.Grade.GOOD)
	_check("items: potion heals", neuro.get_health() > before)
	_check("items: potion consumed from inventory", not GameState.inventory.has(&"potion"))

	arena.queue_free()
	await get_tree().process_frame

#endregion


#region 19. boss ult gauge

func _test_boss_ult_gauge() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.ult_charge = 0

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_queen.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame
	_check("boss: arena flags a boss fight", arena.is_boss)
	_check("boss: gauge shown for a boss enemy", arena.ui.get_node("BossUltBar").visible)
	arena.change_ult_charge(20, true)
	_check("boss: gauge tracks charge", (arena.ui.get_node("BossUltBar") as ProgressBar).value == 20)

	var queen := arena.enemies[0]
	arena.boss_ult_charge = 0
	_check("boss: ult held back while gauge is empty", not _ai_picks_ult(arena, queen))
	arena.boss_ult_charge = arena.max_boss_ult_charge
	_check("boss: ult unlocked when gauge is full", _ai_picks_ult(arena, queen))
	arena.queue_free()
	await get_tree().process_frame

	var normal := _new_arena()
	normal.start_battle([load("res://data/combatants/swarm_drone.tres") as EnemyData] as Array[EnemyData])
	await get_tree().process_frame
	_check("boss: gauge hidden for normal enemies", not normal.ui.get_node("BossUltBar").visible)
	normal.queue_free()
	await get_tree().process_frame


func _ai_picks_ult(arena: Arena, enemy: Combatant) -> bool:
	return arena.ai.choose_action(enemy, arena) is Ultimate

#endregion


#region 20. action menu

func _test_action_menu() -> void:
	GameState.party.members.clear()
	GameState.party.add_member(load("res://data/combatants/neuro.tres") as PartyMember)
	GameState.party.ult_charge = 0
	GameState.inventory = Inventory.new()

	var arena := _new_arena()
	var enemies: Array[EnemyData] = [load("res://data/combatants/swarm_drone.tres") as EnemyData]
	arena.start_battle(enemies)
	await get_tree().process_frame

	var chosen: Array[ActionBase] = []
	var noop := func() -> void: pass
	arena.ui.show_action_menu(
		arena.available_actions_for(arena.party[0]),
		func(action: ActionBase) -> void: chosen.append(action),
		noop,
		noop,
	)
	await get_tree().process_frame

	var grid: GridContainer = arena.ui.get_node("MainBG/Control/ActionMenu/Grid")
	var tab_view: Control = arena.ui.get_node("MainBG/Control/ActionMenu/TabView")
	var action_scroll: ScrollContainer = arena.ui.get_node("MainBG/Control/ActionMenu/TabView/Actions/SkillsScroll")
	var action_list: VBoxContainer = arena.ui.get_node("MainBG/Control/ActionMenu/TabView/Actions/SkillsScroll/Skills")
	var info: Control = arena.ui.get_node("InfoBG")
	var info_label: RichTextLabel = arena.ui.get_node("InfoBG/MarginContainer/Label")
	var enemy := arena.enemies[0]
	_check("menu: grid shown by default", grid.visible and not tab_view.visible)
	_check("menu: six commands in the grid", grid.get_child_count() == 6)
	_check("menu: grid is 3 columns", grid.columns == 3)
	var expected_grid: Array[String] = ["Attack", "Skills", "Combos", "Items", "Inspect", "Flee"]
	var actual_grid: Array[String] = []
	for child in grid.get_children():
		actual_grid.append(String(child.name))
	_check("menu: grid commands are in scene order", actual_grid == expected_grid)
	_check("menu: grid fits its area", grid.get_combined_minimum_size().y <= grid.size.y)

	var skills: Button = arena.ui.get_node("MainBG/Control/ActionMenu/Grid/Skills")
	var combos: Button = arena.ui.get_node("MainBG/Control/ActionMenu/Grid/Combos")
	var back: Button = arena.ui.get_node("MainBG/Control/ActionMenu/TabView/BackBar/Back")
	var tab_title: Button = arena.ui.get_node("MainBG/Control/ActionMenu/TabView/BackBar/Title")
	skills.pressed.emit()
	await get_tree().process_frame
	_check("menu: tab replaces the grid", tab_view.visible and not grid.visible)
	_check("menu: skill list is populated", action_list.get_child_count() > 0)
	_check("menu: skill list fits or scrolls", action_list.size.y <= action_scroll.size.y or action_scroll.get_v_scroll_bar().max_value > 0.0)
	_check("menu: tab title shows current tab", tab_title.text == "Skills")
	var first_skill := action_list.get_child(0)
	combos.pressed.emit()
	await get_tree().process_frame
	_check("menu: tab title updates", tab_title.text == "Combos")
	skills.pressed.emit()
	await get_tree().process_frame
	_check("menu: tab switch keeps list nodes", action_list.get_child(0) == first_skill)
	var first_action := action_list.get_child(0) as Button
	var last_action := action_list.get_child(action_list.get_child_count() - 1) as Button
	_check("menu: top of action list stays", first_action.find_valid_focus_neighbor(SIDE_TOP) == first_action)
	_check("menu: bottom of action list stays", last_action.find_valid_focus_neighbor(SIDE_BOTTOM) == last_action)

	for child in action_list.get_children():
		if (child as Button).text == "Healing Touch":
			(child as Button).focus_entered.emit()
			break
	_check("menu: mana cost is in the description", info_label.text.contains("MP: 3"))
	_check("menu: heal shows its actual value", info_label.text.contains("Healing: 7"))

	var magic_blast_button: Button = null
	for child in action_list.get_children():
		if (child as Button).text == "Magic Blast":
			magic_blast_button = child
			break
	_check("menu: magic blast is listed", magic_blast_button != null)
	if magic_blast_button != null:
		magic_blast_button.focus_entered.emit()
	_check("menu: attack shows its actual magic damage", info_label.text.contains("Magic damage: 15"))

	back.pressed.emit()
	_check("menu: back returns to the grid", grid.visible and not tab_view.visible)
	_check("menu: hidden list keeps its actions", action_list.get_child_count() > 0)

	(grid.get_child(0) as Button).pressed.emit()
	_check("menu: attack shortcut picks basic attack", chosen.size() == 1 and chosen[0].display_name == &"Basic Attack")

	var was_visible := info.visible
	var toggle := InputEventAction.new()
	toggle.action = &"toggle_info"
	toggle.pressed = true
	arena.ui._unhandled_input(toggle)
	_check("menu: info panel toggles", info.visible != was_visible)

	var hint: Label = arena.ui.get_node("InfoHint")
	var toggle_event := InputMap.action_get_events(&"toggle_info")[0] as InputEventKey
	_check("menu: info hint names the hide key", hint.text.contains(OS.get_keycode_string(toggle_event.physical_keycode)))
	_check("menu: info hint stays visible when hidden", hint.is_visible_in_tree())
	var expected_verb := "hide" if info.visible else "show"
	_check("menu: info hint follows the panel", hint.text.contains(expected_verb))

	var highlighted: Array[Combatant] = []
	arena.target_indicator.highlight_changed.connect(func(c: Combatant) -> void: highlighted.append(c))
	arena.target_indicator.choose(arena.get_alive_enemies())
	await get_tree().process_frame
	_check("menu: mouse hover finds enemy", arena.target_indicator.candidate_at(enemy.sprite.global_position) == enemy)
	_check("menu: controller highlight reports enemy", highlighted.size() == 1 and highlighted[0] == enemy)
	arena.target_indicator.select(enemy)
	await get_tree().process_frame

	arena.queue_free()
	await get_tree().process_frame

#endregion
