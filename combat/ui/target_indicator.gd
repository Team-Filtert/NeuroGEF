class_name TargetIndicator
extends Node2D

## Moves between the candidate combatants and returns the chosen one, or null if
## the player cancels. Draws itself as a simple arrow, so no art is required.

signal highlight_changed(candidate: Combatant)

var _candidates: Array[Combatant] = []
var _index := 0
var _chosen: Combatant
var _cancelled := false
var _active := false


## Awaits the player's pick. Returns the target, or null on cancel.
func choose(candidates: Array[Combatant]) -> Combatant:
	if candidates.is_empty():
		return null

	_candidates = candidates
	_index = 0
	_chosen = null
	_cancelled = false
	_active = true
	visible = true
	_snap_to_current()
	highlight_changed.emit(_candidates[_index])
	queue_redraw()

	while _chosen == null and not _cancelled:
		await get_tree().process_frame

	_active = false
	visible = false
	return _chosen


## Moves the arrow to [param candidate] without choosing it (mouse hover).
func hover(candidate: Combatant) -> void:
	if not _active:
		return
	var index := _candidates.find(candidate)
	if index >= 0 and index != _index:
		_index = index
		_snap_to_current()
		highlight_changed.emit(candidate)


## Chooses [param candidate] immediately (mouse click).
func select(candidate: Combatant) -> void:
	if _active and _candidates.has(candidate):
		_chosen = candidate


## Returns the active candidate under [param position], or null.
func candidate_at(position: Vector2) -> Combatant:
	if not _active:
		return null
	for candidate in _candidates:
		var sprite: Sprite2D = candidate.sprite
		if sprite.get_rect().has_point(sprite.to_local(position)):
			return candidate
	return null


func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseMotion:
		var hovered := candidate_at(get_global_mouse_position())
		if hovered != null:
			hover(hovered)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked := candidate_at(get_global_mouse_position())
		if clicked != null:
			select(clicked)
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	if event.is_action_pressed(&"ui_up") or event.is_action_pressed(&"move_up"):
		_index = wrapi(_index - 1, 0, _candidates.size())
		_snap_to_current()
		highlight_changed.emit(_candidates[_index])
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_down") or event.is_action_pressed(&"move_down"):
		_index = wrapi(_index + 1, 0, _candidates.size())
		_snap_to_current()
		highlight_changed.emit(_candidates[_index])
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"interact"):
		_chosen = _candidates[_index]
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_cancel"):
		_cancelled = true
		get_viewport().set_input_as_handled()


func _snap_to_current() -> void:
	global_position = _candidates[_index].global_position + Vector2(0, -44)


func _draw() -> void:
	var points := PackedVector2Array([Vector2(0, 0), Vector2(-6, 10), Vector2(6, 10)])
	draw_colored_polygon(points, Color(1.0, 0.9, 0.2))
	draw_polyline(points, Color(0, 0, 0, 0.7), 1.0)
