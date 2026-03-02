extends CharacterBody2D

@export var speed := 200.0
@onready var character_animator: CharacterAnimator = $CharacterAnimator

var last_input := Vector2.DOWN

func _physics_process(_delta: float) -> void:
	#var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
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
		character_animator.play_idle(last_input)
		return
		
	velocity = input * speed
	character_animator.play_moving(input)
	last_input = input
	move_and_slide()
