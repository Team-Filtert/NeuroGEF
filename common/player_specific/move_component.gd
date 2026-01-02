extends Node
class_name MoveComponent

@export var parent: CharacterBody2D
@export var inputComponent: InputComponent
@export var speed: float = 100

func _physics_process(_delta):
	if not inputComponent:
		return

	parent.velocity = Vector2.ZERO
	
	var _speed = speed

	parent.velocity = inputComponent.get_directional_input() * _speed
	
	parent.move_and_slide()
	
