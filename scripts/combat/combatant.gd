class_name Combatant
extends Node2D

var display_name: String
var max_health: int
var attack: int
var health: int

var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

func setup(data: CombatantData) -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer

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
		animation_player.play("dead")
		
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]
	
func is_alive() -> bool:
	return health > 0

func set_selected(selected: bool) -> void:
	if selected:
		if animation_player.current_animation != "selected":
			animation_player.play("selected")
	else:
		if animation_player.current_animation != "default":
			animation_player.play("default")