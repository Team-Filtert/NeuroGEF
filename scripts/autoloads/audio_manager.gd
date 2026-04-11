extends Node

enum MusicMode {
	MENU,
	OVERWORLD,
	COMBAT,
	SAVED,
	CUSTOM,
}

const menu_music: AudioStream = preload("res://assets/audio/nere_v2.ogg")

@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer

var overworld_music: AudioStream
var combat_music: AudioStream
var saved_music_stream: AudioStream
var saved_music_position: float

func _ready() -> void:
	music_player.stream = menu_music
	music_player.play()
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_started():
	save_music_state()

func _on_timeline_ended():
	if !CombatManager.is_in_combat:
		change_music(MusicMode.SAVED)

func change_music(music_mode: MusicMode, custom_music: AudioStream = null):
	print(music_mode)
	match music_mode:
		MusicMode.MENU:
			play(menu_music)
		MusicMode.OVERWORLD:
			play(overworld_music)
		MusicMode.COMBAT:
			play(combat_music)
		MusicMode.SAVED:
			play(saved_music_stream, saved_music_position)
		MusicMode.CUSTOM:
			play(custom_music)

func save_music_state():
	saved_music_stream = music_player.stream
	saved_music_position = music_player.get_playback_position()

func play(stream: AudioStream, position: float = 0.0):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play(position)
