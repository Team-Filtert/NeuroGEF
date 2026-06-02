class_name CharacterAnimator
extends Node

@export var animation_player: AnimationPlayer

enum State {IDLE, MOVING}

var current_state := State.IDLE

func play_idle(direction: Vector2) -> void:
	var animation_name := ""
	
	if abs(direction.x) > abs(direction.y):
		animation_name = "idle_right" if direction.x > 0 else "idle_left"
	else:
		animation_name = "idle_down" if direction.y > 0 else "idle_up"
		
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
	
	current_state = State.IDLE

func play_moving(direction: Vector2) -> void:
	if abs(direction.x) == abs(direction.y) and current_state == State.MOVING:
		return
	
	var animation_name := ""
	
	if abs(direction.x) > abs(direction.y):
		animation_name = "move_right" if direction.x > 0 else "move_left"
	else:
		animation_name = "move_down" if direction.y > 0 else "move_up"
	
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
	
	current_state = State.MOVING
