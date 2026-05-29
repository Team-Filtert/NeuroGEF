extends CharacterBody2D

const SPEED := 300.0

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input * SPEED
	move_and_slide()
	
