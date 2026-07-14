class_name EnteredArea
extends ConditionLeaf

@export var area: Area2D
@export var interaction_key: String


var is_player_close := false
var has_triggered := false

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)

func tick(actor: Node, blackboard: Blackboard) -> int:
	if is_player_close and !has_triggered:
		has_triggered = true
		return SUCCESS
	return FAILURE

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "Player":
		is_player_close = true

func _on_area_2d_body_exited(body: Node2D):
	if body.name == "Player":
		is_player_close = false
		has_triggered = false
