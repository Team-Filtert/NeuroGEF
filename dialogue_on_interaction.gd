extends Interactable

@export var dialogue_scene: DialogueScene

func interact() -> void:
	# Start a dialogue using the GameManager's dialogue manager
	(%GameManager as GameManager).dialogue_manager.start_dialogue(dialogue_scene)
	await (%GameManager as GameManager).dialogue_manager.dialogue_finished
