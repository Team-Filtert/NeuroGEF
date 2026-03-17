class_name Combatant
extends Node2D

var display_name: String
var max_health: int
var health: int
var base_attack: int
var base_speed: int
var base_defense: int

var resource_ref: CombatantData

var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

var is_blocking: bool = false

var is_player_controlled: bool = false

func setup(data: CombatantData, player_controlled: bool = false) -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer

	data.initialize()
	is_player_controlled = player_controlled

	resource_ref = data

	display_name = data.display_name
	max_health = data.max_health
	health = data.health
	base_attack = data.base_attack
	base_speed = data.base_speed
	base_defense = data.base_defense

	sprite.texture = data.texture
	
	$HealthBar.max_value = max_health
	
	$DisplayNameLabel.text = display_name
	update_label()
	
func take_damage(amount: int) -> void:
	var defense = get_defense() * 2 if is_blocking else get_defense()
	var effective_damage: int = max(amount - defense, 0)
	
	$DmgNumLabel.text = str(-effective_damage)
	set_health(health - effective_damage)
	$Timer.start()
	
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
	$HealthBar.value = health


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

func get_defense() -> int:
	return base_defense

func get_attack() -> int:
	return base_attack

func get_speed() -> int:
	return base_speed

func set_blocking(value: bool) -> void:
	is_blocking = value

func reset_status() -> void:
	is_blocking = false

func _on_timer_timeout() -> void:
	$DmgNumLabel.text = ""
