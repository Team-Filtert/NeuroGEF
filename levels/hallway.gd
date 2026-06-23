extends Node2D

func _ready() -> void:
	AudioManager.stop_bgm()
	AudioManager.play_sfx(preload("res://assets/sfx/battle_attackcrit.wav"))
	AudioManager.play_sfx(preload("res://assets/sfx/battle_parry.wav"))
