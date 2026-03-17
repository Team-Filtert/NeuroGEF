class_name ArenaComponent extends Node2D

signal battle_ended

@export var main_combat_menu: MenuHandler

var states: Array[ArenaStateBase]
var current_state: ArenaStateBase

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

func change_state(new_state: ArenaStateBase):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

var awaiting_player_input := true

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var action_queue: Array[CombatantAction] = []
var player_actions_submitted := 0

class PackedAction:
	var selected_combatant: Combatant
	var submitted_action: CombatantAction

	func _init(combatant: Combatant, action: CombatantAction):
		selected_combatant = combatant
		submitted_action = action



@onready var party_slots: Array[Marker2D] = [$"../Party/Slot1", $"../Party/Slot2", $"../Party/Slot3"]
@onready var enemy_slots: Array[Marker2D] = [$"../Enemies/Slot1", $"../Enemies/Slot2", $"../Enemies/Slot3"]
@onready var target_indicator: SelectTargetIndicator = $"../SelectTargetIndicator"

func setup_battle(enemy_data: Array[CombatantData]) -> void:
	party = spawn_combatants(PartyManager.combat_party, party_slots, $"../Party", true)
	enemies = spawn_combatants(enemy_data, enemy_slots, $"../Enemies", false)

	action_queue.clear()
	player_actions_submitted = 0
	get_current_combatant().set_selected(true)
	
	main_combat_menu.configure_focus(true)

	var start_state = states.filter(func(state): return state is ActionGroupState)[0]
	change_state(start_state)

func cleanup_battle() -> void:
	for combatant in party + enemies:
		if is_instance_valid(combatant):
			combatant.queue_free()
	
	party.clear()
	enemies.clear()
	action_queue.clear()
	
func spawn_combatants(combatant_data: Array[CombatantData], slots: Array[Marker2D], parent: Node2D, is_player_controlled: bool = false) -> Array[Combatant]:
	var spawned: Array[Combatant] = []
	var combatant_scene := preload("res://scenes/combat/combatant.tscn")
	
	for i in combatant_data.size():
		var combatant: Combatant = combatant_scene.instantiate()
		
		combatant.setup(combatant_data[i], is_player_controlled)
		combatant.position = slots[i].position
		spawned.append(combatant)
		parent.add_child(combatant)
	
	return spawned



func menu_element_pressed(event: Callable, next_state: ActionSelectState):
	var decorated_func = func():
		if not awaiting_player_input:
			return
		
		var result: PackedAction = await event.call()
		
		if not result:
			print("menu_element_pressed: handled event returned nothing")
			return
		
		var selected_combatant = result.selected_combatant
		var submitted_action = result.submitted_action
	
		action_queue.append(submitted_action)
		player_actions_submitted += 1
		selected_combatant.set_selected(false)

		if player_actions_submitted >= get_alive_party().size():
			change_state(next_state)
		else:
			setup_menus_for_current_character()
			main_combat_menu.configure_focus()
			get_current_combatant().set_selected(true)
	
	return decorated_func

func get_current_combatant() -> Combatant:
	var alive_party := party.filter(func(c: Combatant): return c.is_alive())
	if not alive_party:
		printerr("No alive combatants in party")
		return null
	if player_actions_submitted >= alive_party.size():
		printerr("player_actions_submitted is greater than alive_party size. This should not happen.")
		return null

	return alive_party[player_actions_submitted]

func setup_menus_for_current_character():
	for state in states:
		if state is ActionSelectState:
			state.setup_menu_for_current_character()

func hide_all_submenus():
	for state in states:
		if state is ActionSelectState:
			state.parent.visible = false


func get_alive_party() -> Array[Combatant]:
	return party.filter(func(c: Combatant): return c.is_alive())

func get_alive_enemies() -> Array[Combatant]:
	return enemies.filter(func(c: Combatant): return c.is_alive())

func get_all_alive_combatants() -> Array[Combatant]:
	return get_alive_party() + get_alive_enemies()

func _has_battle_ended() -> bool:
	var alive_enemies := get_alive_enemies()
	var alive_party := get_alive_party()
	
	if alive_enemies.size() == 0:
		end_battle()
		return true
	
	if alive_party.size() == 0:
		end_battle()
		return true
	
	return false

func _save_party_stats() -> void:
	for combatant in party:
		if is_instance_valid(combatant):
			combatant.resource_ref.health = combatant.get_health()

func end_battle() -> void:
	_save_party_stats()
	battle_ended.emit()