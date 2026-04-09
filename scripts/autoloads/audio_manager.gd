extends Node

enum MusicMode {
	MENU,
	OVERWORLD,
	COMBAT,
}

const menu_music: AudioStream = preload("res://assets/audio/nere_v2.ogg")

@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer

var overworld_music: AudioStream
var combat_music: AudioStream

func _ready() -> void:
	music_player.stream = menu_music
	music_player.play()

func change_music(music_mode: MusicMode):
	match music_mode:
		MusicMode.MENU:
			music_player.stream = menu_music
		MusicMode.OVERWORLD:
			music_player.stream = overworld_music
		MusicMode.COMBAT:
			music_player.stream = combat_music
	music_player.play()
