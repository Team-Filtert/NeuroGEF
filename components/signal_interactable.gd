class_name SignalInteractable
extends Node2D

signal interaction_available
signal interaction_triggered
signal interaction_unavailable

@export var enabled := true
@onready var interaction_area: Area2D = $Area2D

var interactor: Node2D = null

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interactor and enabled:
		get_viewport().set_input_as_handled()
		interaction_triggered.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or not enabled:
		interactor = body
		interaction_available.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interactor = null
		interaction_unavailable.emit()
