extends Area2D
class_name TriggerComponent

@export var parent: Node2D

func _on_body_entered(body: Node2D):
	print("TriggerComponent: Body entered trigger area")
	if parent.has_method("on_trigger_area_body_entered"):
		parent.on_trigger_area_body_entered(body)

