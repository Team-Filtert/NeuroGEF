extends Node2D

func _ready() -> void:
	AudioManager.play_bgm(preload("res://assets/home_bgm.ogg"))
