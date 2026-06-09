class_name ArenaComponent
extends Node2D



#region state machine



var states: Array[ArenaStateBase]
var current_state: ArenaStateBase
var main_menu_state: ActionGroupState

# For transfering data between state nodes
var pending_action: CombatantAction

func get_states() -> Array[ArenaStateBase]:
	var items: Array[ArenaStateBase] = []
	for child in get_children():
		if child is ArenaStateBase:
			items.append(child)
	return items

func _ready():
	states = get_states()
	cycle_started.connect(func(): ui_manager.reset_main_menu())

func change_state(new_state: ArenaStateBase):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()



#endregion



#region combat core

@onready var ui_manager: ArenaUIManagerComponent = $ArenaUIManagerComponent
@onready var arena: Arena = get_parent()


signal battle_ended

# emitted when battle cycle started,
# or, in other words, when player's turn is started
signal cycle_started


var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var action_queue: Array[CombatantAction] = []
var player_actions_submitted := 0
var is_boss := false

# Call only on start of the battle
func setup_battle(enemy_data: Array[CombatantData]) -> void:
	party = spawn_combatants(PartyManager.combat_party, party_slots, $"../Party", true)
	enemies = spawn_combatants(enemy_data, enemy_slots, $"../Enemies", false)
	
	reset_turn_state()
	
	is_boss = enemies.any(func(e: Combatant): return e.has_ult)
	ui_manager.setup_ult_display()
	arena.reset_ult_charges()
	
	main_menu_state = states.filter(func(state): return state is ActionGroupState)[0]
	change_state(main_menu_state)

func submit_action_player(action: CombatantAction) -> void:
	submit_action(action)
	get_current_combatant().set_selected(false)
	player_actions_submitted += 1

func submit_action(action: CombatantAction) -> void:
	action_queue.append(action)

func check_player_turn_over() -> bool:
	return player_actions_submitted >= get_alive_party().size();

func reset_turn_state() -> void:
	action_queue.clear()
	player_actions_submitted = 0

func start_over():
	reset_turn_state()
	
	for c in get_all_alive_combatants():
		c.reset_status()
	
	reset_menu()

func reset_menu():
	change_state(main_menu_state)

func _has_battle_ended() -> bool:
	var alive_enemies := get_alive_enemies()
	var alive_party := get_alive_party()
	
	if alive_enemies.size() == 0:
		end_battle(true)
		return true
	
	if alive_party.size() == 0:
		end_battle(false)
		return true
	
	return false

func _save_party_stats() -> void:
	for combatant in party:
		if is_instance_valid(combatant):
			@warning_ignore("integer_division")
			combatant.resource_ref.health = combatant.get_health() if combatant.get_health() != 0 else combatant.get_max_health() / 2
			combatant.resource_ref.mana = combatant.get_mana()

func _award_xp() -> void:
	var xp_reward := 0
	
	for combatant in enemies:
		if is_instance_valid(combatant):
			xp_reward += combatant.resource_ref.xp
	
	for combatant in party:
		if is_instance_valid(combatant):
			combatant.resource_ref.xp += xp_reward

# Call only at the end of the battle
func cleanup_battle() -> void:
	for combatant in party + enemies:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
	party.clear()
	enemies.clear()
	action_queue.clear()

func end_battle(is_victory: bool) -> void:
	_save_party_stats()
	if is_victory:
		_award_xp()
	battle_ended.emit()



#endregion



#region combatants management



@onready var party_slots: Array[Marker2D] = [$"../Party/Slot1", $"../Party/Slot2", $"../Party/Slot3"]
@onready var enemy_slots: Array[Marker2D] = [$"../Enemies/Slot1", $"../Enemies/Slot2", $"../Enemies/Slot3"]
@onready var target_indicator: SelectTargetIndicator = $"../SelectTargetIndicator"


func spawn_combatants(combatant_data: Array[CombatantData], slots: Array[Marker2D], parent: Node2D, is_player_controlled: bool = false) -> Array[Combatant]:
	var spawned: Array[Combatant] = []
	var combatant_scene := preload("res://combat/combatant.tscn")
	
	for i in combatant_data.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup(combatant_data[i], is_player_controlled)
		combatant.position = slots[i].position
		spawned.append(combatant)
		parent.add_child(combatant)
	
	return spawned

func wait_for_target_selection(valid_targets: Array[Combatant]) -> Combatant:
	target_indicator.visible = true
	var selected_target: Combatant = await target_indicator.wait_for_target_selection(valid_targets)
	target_indicator.visible = false
	return selected_target

func get_alive_party() -> Array[Combatant]:
	return party.filter(func(c: Combatant): return c.is_alive())

func get_alive_enemies() -> Array[Combatant]:
	return enemies.filter(func(c: Combatant): return c.is_alive())

func get_all_alive_combatants() -> Array[Combatant]:
	return get_alive_party() + get_alive_enemies()

func get_current_combatant() -> Combatant:
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	if not alive_party:
		printerr("No alive combatants in party")
		return null
	if player_actions_submitted >= alive_party.size():
		printerr("player_actions_submitted is greater than alive_party size. This should not happen.")
		return null

	return alive_party[player_actions_submitted]



#endregion
