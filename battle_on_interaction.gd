extends Interactable


func interact() -> void:
	print("BattleOnInteraction: Starting combat")
	GlobalManager.get_game_manager().start_combat()
	await GlobalManager.get_game_manager().combat_manager.combat_finished