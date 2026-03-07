class_name Combatant
extends Node2D

var display_name: String
var max_health: int
var health: int
var base_attack: int
var base_speed: int

var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

func setup(data: CombatantData) -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer

	data.initialize()

	display_name = data.display_name
	max_health = data.max_health
	health = data.health
	base_attack = data.base_attack
	base_speed = data.base_speed

	sprite.texture = data.texture
	
	$DisplayNameLabel.text = display_name
	update_label()
	
func take_damage(amount: int) -> void:
	set_health(health - amount)
	
	if health == 0:
		animation_player.play("dead")
		
	update_label()
	
func is_alive() -> bool:
	return health > 0

func set_selected(selected: bool) -> void:
	if selected:
		if animation_player.current_animation != "selected":
			animation_player.play("selected")
	else:
		if animation_player.current_animation != "default":
			animation_player.play("default")

func update_label() -> void:
	$HealthLabel.text = "HP: %s / %s" % [health, max_health]


func get_display_name() -> String:
	return display_name

func get_max_health() -> int:
	return max_health
func get_health() -> int:
	return health

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health)

func apply_heal(heal: int) -> void:
	set_health(health + heal)

func get_attack() -> int:
	return base_attack

func get_speed() -> int:
	return base_speed
