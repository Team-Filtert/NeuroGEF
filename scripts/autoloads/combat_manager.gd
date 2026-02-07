extends Node

@onready var combat_layer: CanvasLayer = $/root/Root/CombatLayer
@onready var arena: Arena = $/root/Root/CombatLayer/Arena
@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer

var battle_theme := preload("res://assets/audio/battle_bgm_01.ogg")

func start_combat() -> void:  
	music_player.stream = battle_theme
	music_player.play()
	
	get_tree().paused = true
	combat_layer.visible = true
	
	arena.setup_battle()
	arena.battle_ended.connect(_on_battle_ended)
	
func end_combat() -> void:
	music_player.stop()
	
	get_tree().paused = false
	combat_layer.visible = false
	
	arena.cleanup_battle()
	
func _on_battle_ended() -> void:
	end_combat()
	arena.battle_ended.disconnect(_on_battle_ended)