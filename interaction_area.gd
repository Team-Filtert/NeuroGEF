extends Area2D
class_name InteractionArea

@export var parent: Node2D

func _on_body_exited(body: Node2D):
	if body is PlayerCharacter:
		body.interaction_indicator.hide_indicator()
		body.interactable_object = null

func _on_body_entered(body: Node2D):
	if body is PlayerCharacter:
		body.interaction_indicator.show_indicator()
		body.interactable_object = parent
