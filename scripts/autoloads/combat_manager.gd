class_name CombatManager
extends Node

@export var combat_layer: CanvasLayer
@export var arena: ArenaComponent
@export var music_player: AudioStreamPlayer
@export var transition_effect: Transition
#@onready var transition_effect: Transition = $UIlayer/Transition
var is_in_combat: bool = false

var battle_theme: AudioStreamOggVorbis = preload("res://assets/audio/battle_bgm_01.ogg")

func start_combat(enemies: Array[CombatantData]) -> void:
	is_in_combat = true
	battle_theme.loop = true
	music_player.stream = battle_theme
	music_player.play()
	
	get_tree().paused = true

	await transition_effect.transition_in()
	
	combat_layer.show()
	
	arena.setup_battle(enemies)
	arena.battle_ended.connect(_on_battle_ended)

	await transition_effect.transition_out()
	
func _on_battle_ended() -> void:
	music_player.stop()

	await transition_effect.transition_in()
	is_in_combat = false

	get_tree().paused = false
	combat_layer.hide()
	arena.cleanup_battle()
	arena.battle_ended.disconnect(_on_battle_ended)

	await transition_effect.transition_out()

func _ready():
	GameManager.combat_manager = self
