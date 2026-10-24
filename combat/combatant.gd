class_name Combatant
extends Node2D

## Runtime wrapper around a [CombatantData]. The resource holds the definition
## and the persisted HP/MP; this node owns the live battle state and the visuals.
##
## Stat getters go through here so equipment modifiers can be added later without
## touching anything that reads the stats.

signal died(combatant: Combatant)
signal damaged(amount: int)

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $StatBars/HP/HPBar
@onready var mana_bar: ProgressBar = $StatBars/MP/MPBar

var data: CombatantData
var actions: Array[ActionBase] = []
var is_player_controlled := false
var is_blocking := false
var resting_position := Vector2.ZERO
var status_effects: Array[StatusEffect] = []

var _health := 0
var _mana := 0
var _dead := false


func setup(p_data: CombatantData, p_position: Vector2, p_player_controlled: bool) -> void:
	data = p_data
	is_player_controlled = p_player_controlled
	resting_position = p_position
	position = p_position

	# `fresh` is true on the first game-wide use of the resource. A fresh member
	# starts on a full bar, which is equipment-aware (so gear that raises max
	# HP/MP is filled right away); later battles resume the saved value.
	var fresh := data.ensure_initialized()
	if is_player_controlled and not fresh:
		_health = data.health
		_mana = data.mana
	else:
		_health = get_max_health()
		_mana = get_max_mana()

	sprite.texture = data.texture
	sprite.hframes = maxi(data.sprite_hframes, 1)
	sprite.vframes = maxi(data.sprite_vframes, 1)
	sprite.frame = data.sprite_frame
	# Duplicate the actions so each combatant owns its own source/target.
	for action in data.actions:
		var copy: ActionBase = action.duplicate(true)
		copy.source = self
		actions.append(copy)

	refresh()


#region STATS

func get_attack() -> int:
	return data.attack + _equipment_bonus(&"attack_modifier") + _status_bonus(&"attack")


func get_magic() -> int:
	return data.magic + _equipment_bonus(&"magic_modifier") + _status_bonus(&"magic")


func get_defense() -> int:
	return data.defense + _equipment_bonus(&"defense_modifier") + _status_bonus(&"defense")


func get_speed() -> int:
	return data.speed + _equipment_bonus(&"speed_modifier") + _status_bonus(&"speed")


func get_accuracy() -> int:
	return data.accuracy + _equipment_bonus(&"accuracy_modifier") + _status_bonus(&"accuracy")


func get_max_health() -> int:
	return data.max_health + _equipment_bonus(&"max_health_modifier") + _status_bonus(&"max_health")


func get_max_mana() -> int:
	return data.max_mana + _equipment_bonus(&"max_mana_modifier") + _status_bonus(&"max_mana")


## Sums a modifier property across the equipped weapon, armors and artifacts.
func _equipment_bonus(prop: StringName) -> int:
	var total := 0
	if data.weapon != null:
		total += int(data.weapon.get(prop))
	for armor in data.armors:
		total += int(armor.get(prop))
	for artifact in data.artifacts:
		total += int(artifact.get(prop))
	return total


## Sums active [StatModifier] effects for a plain stat name.
func _status_bonus(stat: StringName) -> int:
	var total := 0
	for effect in status_effects:
		if effect is StatModifier and effect.stat == stat:
			total += effect.amount
	return total


func get_health() -> int:
	return _health


func get_mana() -> int:
	return _mana


func get_display_name() -> String:
	return String(data.display_name)


func has_ult() -> bool:
	return data.has_ult()


func is_alive() -> bool:
	return not _dead and _health > 0

#endregion


#region HEALTH / MANA

## [param piercing] attacks ignore defense. Returns the damage actually dealt.
func take_damage(amount: int, piercing := false) -> int:
	var defense := 0
	if not piercing:
		defense = get_defense()
		if is_blocking:
			defense *= 2

	var dealt := maxi(amount - defense, 0)
	_health = maxi(_health - dealt, 0)
	refresh()

	if dealt > 0:
		damaged.emit(dealt)
	if _health == 0:
		_die()

	return dealt


## Returns the HP actually restored.
func receive_heal(amount: int) -> int:
	var before := _health
	_health = mini(_health + amount, get_max_health())
	refresh()
	return _health - before


func receive_mana(amount: int) -> int:
	var before := _mana
	_mana = mini(_mana + amount, get_max_mana())
	refresh()
	return _mana - before


func spend_mana(amount: int) -> void:
	_mana = maxi(_mana - amount, 0)
	refresh()

#endregion


func set_blocking(value: bool) -> void:
	is_blocking = value


func add_status(effect: StatusEffect) -> void:
	if effect != null and not status_effects.has(effect):
		status_effects.append(effect)


func remove_status(effect: StatusEffect) -> void:
	status_effects.erase(effect)


func set_selected(selected: bool) -> void:
	sprite.modulate = Color(1.5, 1.5, 1.5) if selected else Color.WHITE


func refresh() -> void:
	if health_bar:
		health_bar.max_value = get_max_health()
		health_bar.value = _health
	if mana_bar:
		mana_bar.max_value = get_max_mana()
		mana_bar.value = _mana


## Writes the live HP/MP back into the resource so it survives between battles.
func save_to_data() -> void:
	data.health = _health
	data.mana = _mana


#region MOVEMENT

func move_to(target_position: Vector2, duration := 0.25) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration)
	await tween.finished


func move_home(duration := 0.25) -> void:
	await move_to(resting_position, duration)

#endregion


func _die() -> void:
	if _dead:
		return
	_dead = true
	died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
