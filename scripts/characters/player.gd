extends CharacterBase

@export var input_speed := 200.0

var last_input := Vector2.DOWN
var is_input_control := true

func _ready() -> void:
	connect_animation_nodes()
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _physics_process(delta: float) -> void:
	if is_input_control:
		input_control(delta)
	else:
		script_control(delta)

func input_control(_delta: float) -> void:	
	var input := Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input = Vector2.RIGHT
	
	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
		animate("idle_" + direction_vect_to_string(last_input))
		return
		
	velocity = input * input_speed
	animate("move_" + direction_vect_to_string(input))
	last_input = input
	move_and_slide()

func _on_timeline_started():
	is_input_control = false
	animate("idle_" + direction_vect_to_string(last_input))

func _on_timeline_ended():
	is_input_control = true

func direction_vect_to_string(vector: Vector2) -> String:
	var direction_str: String
	match vector:
		Vector2.UP:
			direction_str = "up"
		Vector2.DOWN:
			direction_str = "down"
		Vector2.LEFT:
			direction_str = "left"
		Vector2.RIGHT:
			direction_str = "rignt"
	return  direction_str
