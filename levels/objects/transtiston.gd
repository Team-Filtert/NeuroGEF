@tool
extends Node2D
class_name Transition

enum FacingDirection { UP, LEFT, DOWN, RIGHT }


const SPAWN_POINT_NAME := "SpawnPoint"
const TRIGGER_NAME := "TransitionTrigger"
const SHAPE_NAME := "CollisionShape2D"
const SPAWN_MARGIN := 16.0

var spawner : SpawnPoint:
	get:
		spawner = get_node_or_null(SPAWN_POINT_NAME) as SpawnPoint
		if spawner == null:
			spawner = SpawnPoint.new()
			spawner.name = SPAWN_POINT_NAME
			add_child(spawner)
		return spawner
var trigger : TransitionTrigger:
	get:
		trigger = get_node_or_null(TRIGGER_NAME) as TransitionTrigger
		if trigger == null:
			trigger = TransitionTrigger.new()
			trigger.name = TRIGGER_NAME
			add_child(trigger)
		return trigger
var shape : CollisionShape2D:
	get:
		shape = trigger.get_node_or_null(SHAPE_NAME) as CollisionShape2D
		if shape == null:
			shape = CollisionShape2D.new()
			shape.name = SHAPE_NAME
			shape.shape = RectangleShape2D.new()
			trigger.add_child(shape)
		return shape

@export var Transition_ID: String
@export_file("*.tscn") var target_scene: String = "res://levels/"
@export_file("*.tscn") var transition_scene: String = "res://transitions/fade_transition.tscn"
@export var hit_box_size := Vector2(32, 32):
	set(value):
		hit_box_size = value
		(shape.shape as RectangleShape2D).size = hit_box_size
		_update_spawner()
			
@export var facing_direction: FacingDirection = FacingDirection.DOWN:
	set(value):
		facing_direction = value
		_update_spawner()


func _update_trigger() -> void:
	trigger.spawn_id = Transition_ID
	trigger.target_scene = target_scene
	trigger.transition_scene = transition_scene
	trigger.position = Vector2.ZERO
	(shape.shape as RectangleShape2D).size = hit_box_size


func _update_spawner() -> void:
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

		
func _ready() -> void:
	_update_trigger()
	_update_spawner()
	spawner.spawn_id = Transition_ID
