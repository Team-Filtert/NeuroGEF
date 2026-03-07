extends Node

@onready var combat_layer: CanvasLayer = $/root/Root/CombatLayer
@onready var arena: Arena = $/root/Root/CombatLayer/Arena
@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer

var battle_theme: AudioStreamOggVorbis = preload("res://assets/audio/battle_bgm_01.ogg")

func start_combat(enemies: Array[CombatantData]) -> void:
	battle_theme.loop = true
	music_player.stream = battle_theme
	music_player.play()
	
	get_tree().paused = true
	combat_layer.show()
	
	arena.setup_battle(enemies)
	arena.battle_ended.connect(_on_battle_ended)
	
func _on_battle_ended() -> void:
	music_player.stop()
	
	get_tree().paused = false
	combat_layer.hide()
	arena.cleanup_battle()
	arena.battle_ended.disconnect(_on_battle_ended)