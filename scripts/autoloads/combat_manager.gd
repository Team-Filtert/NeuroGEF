extends Node

@onready var combat_layer: CanvasLayer = $/root/Root/CombatLayer
@onready var arena: ArenaComponent = $/root/Root/CombatLayer/Arena/ArenaComponent
@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer
@onready var transition_effect: Transition = $/root/Root/TransitionLayer/Transition

var battle_theme: AudioStreamOggVorbis = preload("res://assets/audio/battle_bgm_01.ogg")

func start_combat(enemies: Array[CombatantData]) -> void:
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

	get_tree().paused = false
	combat_layer.hide()
	arena.cleanup_battle()
	arena.battle_ended.disconnect(_on_battle_ended)

	await transition_effect.transition_out()
