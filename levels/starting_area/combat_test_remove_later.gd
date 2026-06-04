extends Area2D

func _on_body_entered(_body: Node) -> void:
	var combatant_data := preload("res://data/enemy_base.tres")
	CombatManager.start_combat([combatant_data, combatant_data, combatant_data])