class_name Combatant
extends Node2D

var combatant_data: CombatantData
var health: int
var max_health: int
var attack: int
var display_name: String

func _ready() -> void:
	update_display()

func setup_from_data(data: CombatantData) -> void:
		var sprite: Sprite2D = $Sprite2D
		
		combatant_data = data
		display_name = data.display_name
		max_health = data.max_health
		health = data.max_health
		attack = data.attack
		sprite.texture = data.sprite
		
func take_damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		hide()
		
	update_display()
	
func show_highlight() -> void:
	$Highlight.show()
	
func hide_highlight() -> void:
	$Highlight.hide()
		
func update_display() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
