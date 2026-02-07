class_name Combatant
extends Node2D

var combatant_name := "Enemy"
var max_health := 100.0
var health := max_health

func _ready() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
	$NameLabel.text = combatant_name
	
func show_attacker_highlight() -> void:
	$AttackerHighlight.show()
	
func show_target_highlight() -> void:
	$TargetHighlight.show()
	
func hide_attacker_highlight() -> void:
	$AttackerHighlight.hide()
	
func hide_target_highlight() -> void:
	$TargetHighlight.hide()
	
func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		health = 0
		hide()
		
	update_display()
	
func update_display() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]