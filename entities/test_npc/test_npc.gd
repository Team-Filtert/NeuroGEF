extends CharacterBody2D

@export var dialogue_scene: DialogueScene
@onready var interactable: SignalInteractable = $SignalInteractable

func _ready() -> void:
	interactable.interaction_triggered.connect(_on_interactable_interaction_triggered)
	
func _on_interactable_interaction_triggered():
	(GlobalManager.get_game_manager() as GameManager).dialogue_manager.start_dialogue(dialogue_scene)
	await (GlobalManager.get_game_manager() as GameManager).dialogue_manager.dialogue_finished