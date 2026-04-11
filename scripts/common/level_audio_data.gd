class_name LevelAudioData
extends Node

@export var overworld_music: AudioStream
@export var combat_music: AudioStream

func _ready() -> void:
	AudioManager.overworld_music = overworld_music
	AudioManager.combat_music = combat_music
	AudioManager.change_music(AudioManager.MusicMode.OVERWORLD)
