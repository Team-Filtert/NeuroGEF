class_name Interacted
extends ConditionLeaf

@export var area: Area2D

var is_player_close := false

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)

func tick(actor: Node, blackboard: Blackboard) -> int:
	if Input.is_action_just_pressed("interact") and is_player_close:
		return SUCCESS
	return FAILURE

func _on_area_2d_body_entered(body: Node2D):
	is_player_close = true

func _on_area_2d_body_exited(body: Node2D):
	is_player_close = false
