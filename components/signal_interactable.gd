class_name SignalInteractable
extends Node

signal interaction_available
signal interaction_unavailable
signal interaction_triggered

@export var interaction_area: Area2D

var interactor: Node2D = null

func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and interactor:
		get_viewport().set_input_as_handled()
		interaction_triggered.emit()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	interactor = body
	interaction_available.emit()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	interactor = null
	interaction_unavailable.emit()
