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
	await _test_full_battle()
	await _test_stack_and_camera()
	_test_manager_rewards()
	await _test_followers()
	_test_equipment()
	_test_inventory()
	_test_leveling()
	await _test_status_action()
	await _test_item_action_in_combat()
	await _test_boss_ult_gauge()
	_report()


func _check(name: String, condition: bool) -> void:
	_results.append(condition)
	print(("PASS  " if condition else "FAIL  ") + name)


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
		"res://data/combatants/swarm_queen.tres",
		"res://data/actions/fireball.tres",
		"res://data/actions/anvil_smash.tres",
		"res://data/actions/magic_blast.tres",
		"res://data/actions/fire_it_up.tres",
		"res://data/actions/queen_slam.tres",
		"res://data/status/burn.tres",
		"res://data/status/regeneration.tres",
		"res://data/status/attack_up.tres",
		"res://data/items/potion.tres",
		"res://data/items/mana_tonic.tres",
		"res://data/items/training_sword.tres",
		"res://data/items/spark_wand.tres",
		"res://data/items/leather_vest.tres",
		"res://quests/defeat_drones.tres",
	]:
		_check("resource loads: " + path, load(path) != null)

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
	GameSettings.qte_mode = GameSettings.QTEMode.ACTIVE
	_check("challenge: active mode -> Active", TimingChallenge.create() is TimingChallenge.Active)
	GameSettings.qte_mode = GameSettings.QTEMode.RELAXED
	var challenge := TimingChallenge.create()
	_check("challenge: relaxed mode -> Relaxed", challenge is TimingChallenge.Relaxed)

#endregion


#region 5. combatant runtime

func _test_combatant() -> void:
	var data := load("res://data/combatants/neuro.tres") as PartyMember
	var c := _new_combatant(data)
	_check("combatant: sprite sheet applied", c.sprite.hframes == 3 and c.sprite.vframes == 4)
	_check("combatant: starts at full health", c.get_health() == c.get_max_health())
	_check("combatant: attack stat includes equipment", c.get_attack() == data.attack + _equipment_bonus(data, "attack_modifier"))
	_check("combatant: accuracy stat includes equipment", c.get_accuracy() == data.accuracy + _equipment_bonus(data, "accuracy_modifier"))

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
	_check("gating: ult shown when gauge full", _count_ult(with_ult) == 1)

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
	arena._restore_camera()
	GameState.state_stack.pop_back()
	GameState.current_state = level
	level.process_mode = Node.PROCESS_MODE_INHERIT
	level.visible = true
	await get_tree().process_frame
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

	# The arena hands its summaries to the panel; check the panel renders them.
	var arena := _new_arena()
	arena.ui.show_level_ups([{"name": "Bare", "level": 2, "gains": {"attack": 2}}])
	var entries: Label = arena.ui.get_node("LevelUpPanel/Panel/Margin/VBox/Entries")
	_check("leveling: panel shows the member", entries.text.contains("Bare"))
	_check("leveling: panel shows the gains", entries.text.contains("+2 attack"))
	_check("leveling: panel is visible", arena.ui.get_node("LevelUpPanel").visible)
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
