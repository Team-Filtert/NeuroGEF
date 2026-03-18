class_name SelectTargetIndicator
extends Node2D

@onready var input_component: UIInputComponent = $InputComponent

var target: Combatant = null
var targets: Array[Combatant] = []
var current_index := 0

func wait_for_target_selection(possible_targets: Array[Combatant]) -> Combatant:
	if not input_component:
		push_error("SelectTargetIndicator requires an InputComponent to function.")
		return null
	
	targets = possible_targets
	target = null

	visible = true
	
	while target == null:
		handle_selection()

		handle_confirm_target()

		if handle_quit_input():
			break

		await get_tree().create_timer(0).timeout

	visible = false
	targets.clear()
	current_index = 0
	return target

func go_to_next_target() -> void:
	if targets.size() == 0:
		return
	
	current_index = (current_index + 1) % targets.size()

func go_to_previous_target() -> void:
	if targets.size() == 0:
		return
	current_index = (current_index - 1 + targets.size()) % targets.size()

func get_current_target() -> Combatant:
	return targets[current_index] if targets.size() > 0 else null

func handle_selection() -> void:
	var selection_input: Vector2 = input_component.get_vector_input()
	if selection_input == Vector2.DOWN:
		go_to_previous_target()
	elif selection_input == Vector2.UP:
		go_to_next_target()
	
	var current_target := get_current_target()
	var target_position: Vector2 = current_target.global_position if current_target else Vector2.ZERO
	global_position = target_position


func handle_confirm_target() -> void:
	var accept_input := input_component.get_accept_input()
	if accept_input:
		target = targets[current_index]

func handle_quit_input() -> bool:
	var cancel_input := input_component.get_cancel_input()
	return cancel_input
