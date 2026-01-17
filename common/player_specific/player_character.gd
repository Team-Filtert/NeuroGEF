extends CharacterBody2D
class_name PlayerCharacter

@export var input_component: InputComponent

@export var interaction_indicator: InteractionIndicator

# This is the only way to prevent unintentional
# multiple sequenced interactions that I can think of rn
@export var interaction_cooldown_timer: Timer

var interactable_object: Interactable = null

func _physics_process(_delta):
	if interactable_object and input_component.get_accept_input() and interaction_cooldown_timer.is_stopped():
		interactable_object.interact()
		interaction_cooldown_timer.start()
		await interaction_cooldown_timer.timeout
		# await interactable_object.interacted

func _ready():
	GlobalManager.set_player(self)

# func _on_interaction_area_body_entered(body):
# 	if body is InteractionArea:
# 		interactable_object = body.parent
# 		interaction_indicator.show_indicator()

# func _on_interaction_area_body_exited(body):
# 	if body is InteractionArea and body.parent == interactable_object:
# 		interactable_object = null
# 		interaction_indicator.hide_indicator()
