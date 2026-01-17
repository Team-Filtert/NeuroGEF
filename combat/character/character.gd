extends Node2D
class_name Character

@export var char_name: String
@export var player_character_resource: PartyMember:
	set(value):
		player_character_resource = value
		char_name = value.char_name
		sprite.texture = value.battle_sprite
		animation_player.add_animation_library('char_combat_anim', value.animation_library)
		animation_player.play("char_combat_anim/idle")
@export var enemy_character_resource: EnemyCharacter:
	set(value):
		enemy_character_resource = value
		char_name = value.char_name
		print("Set enemy: " + value.char_name)
		sprite.texture = value.battle_sprite
		animation_player.add_animation_library('char_combat_anim', value.animation_library)
		animation_player.play("char_combat_anim/idle")
		animation_player.speed_scale = -1.2

@export var cursor: Node2D
var stats: Stat:
	get:
		if is_player:
			if player_character_resource:
				return player_character_resource.stats
			else:
				return null
		else:
			if enemy_character_resource:
				return enemy_character_resource.stats
			else:
				return null

var actions: Array[MeleeCombatAction]:
	get:
		if is_player:
			if player_character_resource:
				return player_character_resource.actions
			else:
				return []
		
		if enemy_character_resource:
			return enemy_character_resource.actions
		else:
			return []
var magic: Array[MagicCombatAction]:
	get:
		if is_player:
			if player_character_resource:
				return player_character_resource.magic
			else:
				return []
		
		if enemy_character_resource:
			return enemy_character_resource.magic
		else:
			return []
signal turn_end()

@export var combat_ui: CombatUIManager
@export var is_player: bool

func get_is_player():
	return is_player

@export var left_target: Marker2D
@export var right_target: Marker2D

@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer

func get_target_pos():
	if is_player and left_target:
		return left_target.global_position
	if not is_player and right_target:
		return right_target.global_position
	push_error("Cannot get target position for character")

var selected_action: Callable = Callable()

signal on_health_changed(amount: int)
signal on_mana_changed(amount: int)


func turn_process():
	if is_player:
		await combat_ui.get_user_input(self)
	else:
		await combat_ui.get_bot_input(self)

	if selected_action.is_valid():
		var code_result = await selected_action.call()
		if code_result == 1:
			return code_result
		selected_action = Callable()
	else:
		print("No action selected for character: " + char_name)

	turn_end.emit()
	return 0

func get_damage(amount: int):
	stats.get_damage(amount)
	on_health_changed.emit(stats.get_health())

func spend_mana(amount: int):
	stats.get_damage(amount)
	on_mana_changed.emit(stats.get_mana())
