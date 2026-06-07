class_name LevelUpUI
extends Node2D

@export var sprite: Sprite2D
@export var random_bonus_label: Label
@export var max_health_button: Button
@export var max_mana_button: Button
@export var attack_button: Button
@export var defense_button: Button
@export var speed_button: Button
@export var magic_button: Button
@export var accuracy_button: Button
@export var menu_handler: VBoxMenuHandler

func _ready() -> void:
	max_health_button.pressed.connect(LevelUpManager._on_max_health_pressed)
	max_mana_button.pressed.connect(LevelUpManager._on_max_mana_pressed)
	attack_button.pressed.connect(LevelUpManager._on_attack_pressed)
	defense_button.pressed.connect(LevelUpManager._on_defense_pressed)
	speed_button.pressed.connect(LevelUpManager._on_speed_pressed)
	magic_button.pressed.connect(LevelUpManager._on_magic_pressed)
	accuracy_button.pressed.connect(LevelUpManager._on_accuracy_pressed)

func setup_ui():
	sprite.texture = LevelUpManager.current_character.texture
	random_bonus_label.text = "select a stat to increase by %d" % LevelUpManager.random_bonus
	menu_handler.configure_focus()
	
	_update_stat_text(LevelUpManager.Stat.MAX_HEALTH)
	_update_stat_text(LevelUpManager.Stat.MAX_MANA)
	_update_stat_text(LevelUpManager.Stat.ATTACK)
	_update_stat_text(LevelUpManager.Stat.DEFENSE)
	_update_stat_text(LevelUpManager.Stat.SPEED)
	_update_stat_text(LevelUpManager.Stat.MAGIC)
	_update_stat_text(LevelUpManager.Stat.ACCURACY)

func reset_ui(raised_stat: LevelUpManager.Stat):
	random_bonus_label.text = "select a stat to increase by %d" % LevelUpManager.random_bonus
	menu_handler.configure_focus()
	_update_stat_text(raised_stat)

func _update_stat_text(raised_stat: LevelUpManager.Stat):
	match raised_stat:
		LevelUpManager.Stat.MAX_HEALTH:
			max_health_button.text = _create_button_text("max health",
					LevelUpManager.current_character.max_health, LevelUpManager.max_health_increase)
		LevelUpManager.Stat.MAX_MANA:
			max_mana_button.text = _create_button_text("max mana",
					LevelUpManager.current_character.max_mana, LevelUpManager.max_mana_increase)
		LevelUpManager.Stat.ATTACK:
			attack_button.text = _create_button_text("attack",
					LevelUpManager.current_character.base_attack, LevelUpManager.attack_increase)
		LevelUpManager.Stat.DEFENSE:
			defense_button.text = _create_button_text("defense",
					LevelUpManager.current_character.base_defense, LevelUpManager.defense_increase)
		LevelUpManager.Stat.SPEED:
			speed_button.text = _create_button_text("speed",
					LevelUpManager.current_character.base_speed, LevelUpManager.speed_increase)
		LevelUpManager.Stat.MAGIC:
			magic_button.text = _create_button_text("magic",
					LevelUpManager.current_character.base_magic, LevelUpManager.magic_increase)
		LevelUpManager.Stat.ACCURACY:
			accuracy_button.text = _create_button_text("accuracy",
					LevelUpManager.current_character.base_accuracy, LevelUpManager.accuracy_increase)

func _create_button_text(stat_name: String, current_value: int, value_increase: int):
	return "%s: %d + %d" % [stat_name, current_value, value_increase]
