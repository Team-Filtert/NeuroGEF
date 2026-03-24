extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if CombatManager.is_in_combat:
		hide()
	else:
		show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CombatManager.is_in_combat:
		hide()
	else:
		show()
