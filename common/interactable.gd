extends Node2D
class_name Interactable

signal interacted


func interact() -> void:
	await get_tree().create_timer(0).timeout
	interacted.emit()
	pass
