class_name Player
extends CharacterBody2D

const SPEED := 180.0

@onready var animation_tree: AnimationTree = $AnimationTree

var last_facing_direction := Vector2.DOWN
var conflict_direction_mask := Vector2.DOWN

func _ready() -> void:
	# NOTE: These should be disconnected if the player ever exits the tree but isn't freed.
	LevelManager.level_load_started.connect(_on_level_load_started)
	LevelManager.spawn_point_available.connect(_on_spawn_point_available)
	LevelManager.level_load_finished.connect(_on_level_load_finished)

func _on_level_load_started() -> void:
	_set_active(false)

func _on_spawn_point_available(spawn_point: SpawnPoint) -> void:
	if spawn_point:
		global_position = spawn_point.global_position
		_set_facing(spawn_point.get_facing_vector())

func _on_level_load_finished() -> void:
	_set_active(true)

func _set_facing(dir: Vector2) -> void:
	last_facing_direction = dir
	animation_tree.set("parameters/Idling/blend_position", dir)
	animation_tree.set("parameters/Walking/blend_position", dir)

func _set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	var input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

	if input.x != 0 and input.y != 0:
		input *= conflict_direction_mask
	else:
		conflict_direction_mask = abs(Vector2(input.y, input.x))
		
	if not input.is_zero_approx() and last_facing_direction != input:
		_set_facing(input)

	velocity = input * SPEED
	move_and_slide()