extends Node2D


func on_trigger_area_body_entered(body):
	if body is PlayerCharacter:
		%GameManager.start_combat()
