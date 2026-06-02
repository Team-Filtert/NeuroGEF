class_name Interactable
extends Area2D

signal interaction_triggered

@export var enabled := true

var interactor: Node2D = null

var input_handler: InputComponent

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	input_handler = InputComponent.new()

func _unhandled_input(event: InputEvent) -> void:
	if input_handler.get_interact_input(event) and interactor and enabled:
		get_viewport().set_input_as_handled()
		interaction_triggered.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and enabled:
		interactor = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interactor = null
