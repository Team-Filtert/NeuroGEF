class_name Combatant
extends Node2D

var combatant_name := "Combatant"
var max_health := 100.0
var health := max_health

func _ready() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
	$NameLabel.text = combatant_name
	
func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		health = 0
		die()
		
	update_display()
		
func die() -> void:
	queue_free()
	
func update_display() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]