extends CharacterBase

@export var input_speed := 200.0

@onready var input_component: InputComponent = $InputComponent

var last_input := Vector2.DOWN
var last_direction_str := "down"
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
	if not input_component:
		return
	
	var input: Vector2 = input_component.get_vector_input()
	
	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
		animate("idle_" + direction_vect_to_string(last_input))
		return
		
	velocity = input * input_speed
	var dir_str = direction_vect_to_string(input)
	if dir_str:
		animate("move_" + dir_str)
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
			last_direction_str = direction_str
		Vector2.DOWN:
			direction_str = "down"
			last_direction_str = direction_str
		Vector2.LEFT:
			direction_str = "left"
			last_direction_str = direction_str
		Vector2.RIGHT:
			direction_str = "right"
			last_direction_str = direction_str
		_:
			direction_str = last_direction_str
	return  direction_str
