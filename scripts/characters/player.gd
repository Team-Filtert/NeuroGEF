extends CharacterBody2D

@export var speed := 200.0
@onready var character_animator: CharacterAnimator = $CharacterAnimator

@onready var input_component: InputComponent = $InputComponent

var last_input := Vector2.DOWN

func _physics_process(_delta: float) -> void:	
	if not input_component:
		return
	
	var input: Vector2 = input_component.get_vector_input()
	
	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
		character_animator.play_idle(last_input)
		return
		
	velocity = input * speed
	character_animator.play_moving(input)
	last_input = input
	move_and_slide()
