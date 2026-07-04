@tool
extends Area2D

@export_file("*.tscn") var target: String:
	set(value):
		target = value
		update_configuration_warnings()
				
# TODO: The spawning stuff
@export var spawn_id := "default"

func _on_body_entered(_body: Node2D) -> void:
	LevelManager.load_level(target)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if target.is_empty():
		warnings.append("Target not set.")

	return warnings
