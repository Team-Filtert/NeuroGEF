extends Node2D

func _ready() -> void:
	AudioManager.stop_bgm()
	AudioManager.play_sfx(preload("res://assets/test_sfx_1.wav"))
	AudioManager.play_sfx(preload("res://assets/test_sfx_2.wav"))