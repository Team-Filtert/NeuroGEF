extends Interactable

@export var dialogue_scene: DialogueScene

func interact() -> void:
	# Start a dialogue using the GameManager's dialogue manager
	(GlobalManager.get_game_manager() as GameManager).dialogue_manager.start_dialogue(dialogue_scene)
	await (GlobalManager.get_game_manager() as GameManager).dialogue_manager.dialogue_finished
