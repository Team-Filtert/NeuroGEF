class_name Combatant
extends Node2D

var display_name: String
var max_health: int
var health: int
var max_mana: int
var mana: int
var base_attack: int
var base_speed: int
var base_defense: int
var base_magic: int #temp for AI testing
var level: int

var wepon: ItemWepon
var armors: Array[ItemArmor]
var artifacts: Array[ItemArtifact]

var attack_actions: Array[CombatantAction]

var resource_ref: CombatantData

var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null

var is_blocking: bool = false

var is_player_controlled: bool = false

var has_ult: bool

func setup(data: CombatantData, player_controlled: bool = false) -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer
	
	data.initialize()
	is_player_controlled = player_controlled
	
	resource_ref = data
	
	display_name = data.display_name
	sprite.texture = data.texture
	max_health = data.max_health
	max_mana = data.max_mana
	base_attack = data.base_attack
	base_speed = data.base_speed
	base_defense = data.base_defense
	level = data.level
	wepon = data.weapon
	armors = data.armors
	artifacts = data.artifacts
	
	if is_player_controlled:
		health = data.health
		mana = data.mana
	else:
		health = max_health
		mana = max_mana
	
	$HealthBar.max_value = max_health
	$ManaBar.max_value = max_mana
	
	$DisplayNameLabel.text = "level %d %s" % [level, display_name]
	update_health_label()
	update_mana_label()
	
	# Get duplicated actions with source
	has_ult = false
	attack_actions.assign(data.attack_actions.map(
		func(action: CombatantAction):
			var processed_action = action.duplicate(true)
			processed_action.source = self
			has_ult = true if processed_action is CombatantUltAction else has_ult
			return processed_action
	))

func take_damage(amount: int) -> int:
	var defense = get_defense() * 2 if is_blocking else get_defense()
	var effective_damage: int = max(amount - defense, 0)
	
	$HealthBar/DmgNumLabel.text = str(-effective_damage)
	set_health(get_health() - effective_damage)
	$Timer.start()
	
	if health == 0:
		animation_player.play("dead")
	
	update_health_label()
	return amount - effective_damage

func loose_mana(amount: int) -> void:
	set_mana(get_mana() - amount)
	update_mana_label()

func is_alive() -> bool:
	return health > 0

func set_selected(selected: bool) -> void:
	if selected:
		if animation_player.current_animation != "selected":
			animation_player.play("selected")
	else:
		if animation_player.current_animation != "default":
			animation_player.play("default")

func update_health_label() -> void:
	$HealthBar/HealthLabel.text = "HP: %d / %d" % [get_health(), get_max_health()]
	$HealthBar.value = get_health()

func update_mana_label() -> void:
	$ManaBar/ManaLabel.text = "MP: %d / %d" % [get_mana(), get_max_mana()]
	$ManaBar.value = get_mana()

func get_display_name() -> String:
	return display_name

func get_max_health() -> int:
	var max_hp := max_health
	if wepon != null:
		max_hp += wepon.max_health_modifier
	for armor in armors:
		max_hp += armor.max_health_modifier
	for artifact in artifacts:
		max_hp += artifact.max_health_modifier
	return max_hp

func get_health() -> int:
	return health

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health)

func apply_heal(heal: int) -> void:
	set_health(health + heal)

func get_max_mana() -> int:
	var max_mp := max_mana
	if wepon != null:
		max_mp += wepon.max_mana_modifier
	for armor in armors:
		max_mp += armor.max_mana_modifier
	for artifact in artifacts:
		max_mp += artifact.max_mana_modifier
	return max_mp

func get_mana() -> int:
	return mana

func set_mana(value: int) -> void:
	mana = clamp(value, 0, max_mana)

func get_defense() -> int:
	var defense := base_defense
	if wepon != null:
		defense += wepon.defense_modifier
	for armor in armors:
		defense += armor.defense_modifier
	for artifact in artifacts:
		defense += artifact.defense_modifier
	return defense

func get_attack() -> int:
	var attack := base_attack
	if wepon != null:
		attack += wepon.attack_modifier
	for armor in armors:
		attack += armor.attack_modifier
	for artifact in artifacts:
		attack += artifact.attack_modifier
	return attack

func get_speed() -> int:
	var speed := base_speed
	if wepon != null:
		speed += wepon.speed_modifier
	for armor in armors:
		speed += armor.speed_modifier
	for artifact in artifacts:
		speed += artifact.speed_modifier
	return speed

func set_blocking(value: bool) -> void:
	is_blocking = value

func reset_status() -> void:
	is_blocking = false

func _on_timer_timeout() -> void:
	$HealthBar/DmgNumLabel.text = ""
