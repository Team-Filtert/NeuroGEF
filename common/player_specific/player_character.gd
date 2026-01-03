extends CharacterBody2D
class_name PlayerCharacter

@export var input_component: InputComponent

@export var interaction_indicator: InteractionIndicator

var interactable_object: Interactable = null

func _physics_process(_delta):
	if interactable_object and input_component.get_accept_input():
		interactable_object.interact()
		await interactable_object.interacted

# func _on_interaction_area_body_entered(body):
# 	if body is InteractionArea:
# 		interactable_object = body.parent
# 		interaction_indicator.show_indicator()

# func _on_interaction_area_body_exited(body):
# 	if body is InteractionArea and body.parent == interactable_object:
# 		interactable_object = null
# 		interaction_indicator.hide_indicator()
