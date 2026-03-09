class_name MiniGameBase
extends Node2D

signal minigame_completed(success: bool, value: int)

func do_minigame() -> void:
	pass

func complete_minigame(success: bool, value: int) -> void:
	minigame_completed.emit(success, value)

	queue_free()

