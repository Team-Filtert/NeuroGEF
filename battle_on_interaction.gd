extends Interactable


func interact() -> void:
	print("BattleOnInteraction: Starting combat")
	%GameManager.start_combat()
