class_name QteBar
extends Control

## Active-mode timing challenge: a marker sweeps once across a bar and the player
## presses accept near the centre. The bar shows a colored section per grade (see
## [TimingGrade]) and the marker is colored by the grade it would currently score.
##
## The bar is authored in [code]qte_bar.tscn[/code]. Tune the feel from the band
## exports below; the accuracy stat widens every band (and its section).

const MARKER_WIDTH := 4.0
const ACCEPT_ACTIONS: Array[StringName] = [&"ui_accept", &"interact"]
const SECTION_ALPHA := 0.5

@onready var _track: ColorRect = $Track
@onready var _sections: Control = $Sections
@onready var _marker: ColorRect = $Marker

@export var sweep_time: float = 0.9
@export var band_perfect: float = 0.03
@export var band_super: float = 0.07
@export var band_good: float = 0.13
@export var band_ok: float = 0.22
@export var band_bad: float = 0.34
## Extra band width per point of accuracy.
@export var accuracy_window_bonus: float = 0.01

var _progress := 0.0
var _running := false
var _grade := TimingGrade.Grade.FAIL
var _multiplier := 1.0


func _ready() -> void:
	_rebuild_sections()
	_update_marker()


func setup(accuracy: int) -> void:
	_multiplier = 1.0 + maxf(accuracy, 0.0) * accuracy_window_bonus
	_rebuild_sections()


## Runs the challenge and returns the resulting [enum TimingGrade.Grade].
func play() -> int:
	_running = true
	_progress = 0.0
	_update_marker()
	while _running:
		await get_tree().process_frame
		_progress += get_process_delta_time() / sweep_time
		_update_marker()
		if _progress >= 1.0:
			_finish(TimingGrade.Grade.FAIL)
	return _grade


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	for action in ACCEPT_ACTIONS:
		if event.is_action_pressed(action):
			_finish(grade_for(_progress))
			get_viewport().set_input_as_handled()
			return


## Maps a marker position (0..1) to a grade. Exposed so it can be tested without
## the UI.
func grade_for(progress: float) -> int:
	var distance := absf(progress - 0.5)
	for band in _bands():
		if distance <= band[1]:
			return band[0]
	return TimingGrade.Grade.FAIL


func _finish(grade: int) -> void:
	if not _running:
		return
	_grade = grade
	_running = false


## Pairs of [grade, half-width in progress units], best band first.
func _bands() -> Array:
	return [
		[TimingGrade.Grade.PERFECT, band_perfect * _multiplier],
		[TimingGrade.Grade.SUPER, band_super * _multiplier],
		[TimingGrade.Grade.GOOD, band_good * _multiplier],
		[TimingGrade.Grade.OK, band_ok * _multiplier],
		[TimingGrade.Grade.BAD, band_bad * _multiplier],
	]


## Draws one colored section per grade, nested from the worst band outwards.
func _rebuild_sections() -> void:
	for child in _sections.get_children():
		_sections.remove_child(child)
		child.queue_free()

	var travel := _track.size.x - MARKER_WIDTH
	var center_x := _track.position.x + _track.size.x * 0.5
	var bands := _bands()
	for i in range(bands.size() - 1, -1, -1):
		var half: float = travel * bands[i][1]
		var section := ColorRect.new()
		section.color = TimingGrade.color(bands[i][0])
		section.color.a = SECTION_ALPHA
		section.position = Vector2(center_x - half, _track.position.y)
		section.size = Vector2(half * 2.0, _track.size.y)
		_sections.add_child(section)


func _update_marker() -> void:
	if _marker == null:
		return
	_marker.position.x = _track.position.x + (_track.size.x - MARKER_WIDTH) * clampf(_progress, 0.0, 1.0)
	_marker.color = TimingGrade.color(grade_for(_progress))
