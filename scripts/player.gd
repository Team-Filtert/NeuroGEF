extends CharacterBody2D

@export var speed := 300.0
@onready var character_animator: CharacterAnimator = $CharacterAnimator

var last_input := Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input == Vector2.ZERO:			
		character_animator.play_idle(last_input)
		return
		
	velocity = input * speed
	character_animator.play_moving(input)
	last_input = input
	move_and_slide()
