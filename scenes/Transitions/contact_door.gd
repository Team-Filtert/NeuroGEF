extends Area2D

@export var connected_scene:String
var scene_folder = "res://scenes/levels/"


func _on_body_entered(body: PhysicsBody2D):
	var full_path = scene_folder + connected_scene + ".tscn"
	get_tree().change_scene_to_file(full_path)
