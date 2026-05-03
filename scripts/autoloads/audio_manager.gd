extends Node

#region volume

var master_bus_idx := AudioServer.get_bus_index("Master")
var music_bus_idx := AudioServer.get_bus_index("Music")
var sfx_bus_idx := AudioServer.get_bus_index("SFX")

func set_master_vol(vol: float):
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(vol))

func set_music_vol(vol: float):
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(vol))

func set_sfx_vol(vol: float):
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(vol))

#endregion

#region music

enum MusicMode {
	MENU,
	OVERWORLD,
	COMBAT,
	SAVED,
	CUSTOM,
}

const menu_music: AudioStream = preload("res://assets/audio/MainThemeTF.ogg")

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
	match music_mode:
		MusicMode.MENU:
			play_music(menu_music)
		MusicMode.OVERWORLD:
			play_music(overworld_music)
		MusicMode.COMBAT:
			play_music(combat_music)
		MusicMode.SAVED:
			play_music(saved_music_stream, saved_music_position)
		MusicMode.CUSTOM:
			play_music(custom_music)

func save_music_state():
	saved_music_stream = music_player.stream
	saved_music_position = music_player.get_playback_position()

func play_music(stream: AudioStream, position: float = 0.0):
	if music_player.stream != stream:
		print(stream)
		music_player.stream = stream
		music_player.play(position)

#endregion

#region sfx

@onready var global_sfx_player: AudioStreamPlayer = $/root/Root/GlobalSfxPlayer

var level_sfx_players: Dictionary[StringName, AudioStreamPlayer2D]

func play_sfx(stream: AudioStream, player_key: StringName):
	match player_key:
		&"global":
			global_sfx_player.stream = stream
			global_sfx_player.play()
		&"player":
			PartyManager.overworld_party[0].audio_player.stream = stream
			PartyManager.overworld_party[0].audio_player.play()
		&"pm1":
			PartyManager.overworld_party[1].audio_player.stream = stream
			PartyManager.overworld_party[1].audio_player.play()
		&"pm2":
			PartyManager.overworld_party[2].audio_player.stream = stream
			PartyManager.overworld_party[2].audio_player.play()
		_:
			level_sfx_players[player_key].stream = stream
			level_sfx_players[player_key].play()

#endregion
