extends Node2D
class_name InputComponent

signal got_any_input()
signal accept_input()
signal cancel_input()
signal got_directiona_input(dir: Vector2i)

func get_accept_input() -> bool:
	return false

func get_cancel_input() -> bool:
	return false

func get_directional_input(_one_time: bool = false) -> Vector2i:
	if _one_time:
		return get_just_pressed_directional_input()
	return Vector2i()

func get_just_pressed_directional_input() -> Vector2i:
	return Vector2i()

# lets pretend it's private please do not change
var got_input = false

func wait_accept_input():
	while not got_input:
		await get_tree().create_timer(0).timeout
		if get_accept_input():
			got_input = true
	got_input = false
	got_any_input.emit()
	accept_input.emit()

func wait_cancet_input():
	while not got_input:
		await get_tree().create_timer(0).timeout
		if get_cancel_input():
			got_input = true
	got_input = false
	got_any_input.emit()
	cancel_input.emit()

func wait_directional_input():
	var dir_input = Vector2i()

	while not got_input:
		await get_tree().create_timer(0).timeout
		dir_input = get_directional_input()

		if dir_input != Vector2i():
			got_input = true

	got_input = false
	got_any_input.emit()
	got_directiona_input.emit(dir_input)

	return dir_input

func wait_any_input():
	while not got_input:
		await get_tree().create_timer(0).timeout
		if get_accept_input() or get_cancel_input() or get_directional_input() != Vector2i():
			got_input = true
	got_input = false
	got_any_input.emit()
	
