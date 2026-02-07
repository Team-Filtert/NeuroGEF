class_name Interactable
extends Area2D

signal interaction_triggered

@export var enabled := true

var interactor: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interactor and enabled:
		get_viewport().set_input_as_handled()
		interaction_triggered.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and enabled:
		interactor = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interactor = null
