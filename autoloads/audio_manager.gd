extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))
	
func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
	
func set_sfx_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(volume))
	
func play_bgm(stream: AudioStream) -> void:
	assert(bgm_player, "AudioManager: bgm_player not set")
	
	if bgm_player.stream == stream and bgm_player.playing:
		return
	
	bgm_player.stream = stream
	bgm_player.play()
	
func stop_bgm() -> void:
	assert(bgm_player, "AudioManager: bgm_player not set")
	
	bgm_player.stop()

func play_sfx(stream: AudioStream) -> void:
	assert(sfx_player, "AudioManager: sfx_player not set")
	
	var playback: AudioStreamPlaybackPolyphonic = sfx_player.get_stream_playback()
	
	playback.play_stream(stream)
