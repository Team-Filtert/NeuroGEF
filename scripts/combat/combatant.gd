class_name Combatant
extends Node2D

var display_name: String
var max_health: int
var attack: int
var health: int

func setup(data: CombatantData) -> void:
	var sprite: Sprite2D = $Sprite2D
	
	sprite.texture = data.texture
	display_name = data.display_name
	max_health = data.max_health
	attack = data.attack
	health = data.max_health
	
	$DisplayNameLabel.text = display_name
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
	
func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	
	if health == 0:
		hide()
		
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
	
func is_alive() -> bool:
	return health > 0