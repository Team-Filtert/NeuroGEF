@tool
extends Node2D
class_name Transition

enum FacingDirection { UP, LEFT, DOWN, RIGHT }

const SPAWN_POINT_NAME := "SpawnPoint"
const TRIGGER_NAME := "TransitionTrigger"
const SPAWN_MARGIN := 16.0

@export var Transition_ID: String
@export_file("*.tscn") var target_scene: String = "res://levels/"
@export_file("*.tscn") var transition_scene: String = "res://transitions/fade_transition.tscn"
@export var hit_box_size := Vector2(32, 32):
	set(value):
		hit_box_size = value
		_update()
@export var facing_direction: FacingDirection = FacingDirection.DOWN:
	set(value):
		facing_direction = value
		_update()

func _ready() -> void:
	_update()

func _update() -> void:
	var spawner := get_node_or_null(SPAWN_POINT_NAME) as SpawnPoint
	if spawner == null:
		spawner = SpawnPoint.new()
		spawner.name = SPAWN_POINT_NAME
		add_child(spawner)
	_update_spawner(spawner)

	var trigger := get_node_or_null(TRIGGER_NAME) as TransitionTrigger
	if trigger == null:
		trigger = TransitionTrigger.new()
		trigger.name = TRIGGER_NAME
		add_child(trigger)
	_update_trigger(trigger)

func _update_trigger(trigger: TransitionTrigger) -> void:
	trigger.spawn_id = Transition_ID
	trigger.target_scene = target_scene
	trigger.transition_scene = transition_scene
	trigger.position = Vector2.ZERO

	var shape: CollisionShape2D = null
	if trigger.get_child_count() > 0:
		shape = trigger.get_child(0) as CollisionShape2D
	if shape == null:
		shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		trigger.add_child(shape)
	(shape.shape as RectangleShape2D).size = hit_box_size

func _update_spawner(spawner: SpawnPoint) -> void:
	spawner.spawn_id = Transition_ID
	spawner.facing_direction = facing_direction as SpawnPoint.FacingDirection

	var distance: float
	match facing_direction:
		FacingDirection.DOWN:
			distance = hit_box_size.y / 2 - 8
		FacingDirection.UP:
			distance = hit_box_size.y / 2 + SPAWN_MARGIN
		_:
			distance = hit_box_size.x / 2 + SPAWN_MARGIN

	match facing_direction:
		FacingDirection.UP: spawner.position = Vector2(0, -distance)
		FacingDirection.DOWN: spawner.position = Vector2(0, distance)
		FacingDirection.LEFT: spawner.position = Vector2(-distance, 0)
		FacingDirection.RIGHT: spawner.position = Vector2(distance, 0)
