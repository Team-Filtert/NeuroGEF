extends Node2D

@export var target: CharacterBody2D
@export var deadzone_radius := 60.0
@export var hover_height := 80.0 
@export var speed_multipier := 3.0
@export var bob_amplitude := 0.5
@export var bob_frequency := 3.0

var velocity := Vector2.ZERO
var bob_time := 0.0

func _physics_process(delta):
	bob_time += delta

	var bob_offset := Vector2(0, bob_amplitude * sin(bob_time * bob_frequency))

	if target:
		var target_position := target.global_position
		
		# Hover over the target only when moving horizontally
		if abs(target.velocity.x) > 0 and target.velocity.y == 0:
			target_position.y -= hover_height

		var distance := global_position.distance_to(target_position)
		
		if distance > deadzone_radius:
			var direction := (target_position - global_position).normalized()
			
			velocity = direction * speed_multipier * (distance - deadzone_radius)
			
	global_position += velocity * delta + bob_offset
