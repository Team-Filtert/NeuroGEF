extends Interactable


func interact() -> void:
	print("BattleOnInteraction: Starting combat")
	%GameManager.start_combat()
	await %GameManager.combat_manager.combat_finished
