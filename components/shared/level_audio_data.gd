class_name LevelAudioData
extends Node

@export var overworld_music: AudioStream
@export var combat_music: AudioStream
@export var level_sfx_players: Dictionary[StringName, AudioStreamPlayer2D] = {}

func _ready() -> void:
	AudioManager.overworld_music = overworld_music
	AudioManager.combat_music = combat_music
	AudioManager.change_music(AudioManager.MusicMode.OVERWORLD)
	AudioManager.level_sfx_players = level_sfx_players
