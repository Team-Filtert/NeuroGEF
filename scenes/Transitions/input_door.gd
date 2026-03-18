extends Area2D

@onready var input_component: PlayerInputComponent = PlayerInputComponent.new()
@export var connected_scene:String
var scene_folder = "res://scenes/levels/"
var entered = false

func _on_body_entered(_body: PhysicsBody2D):
	entered = true
	

func _on_body_exited(_body: PhysicsBody2D):
	entered = false

func _process(_delta: float) -> void:
	if entered == true:
		var full_path = scene_folder + connected_scene + ".tscn"
		var accept_input := input_component.get_accept_input()
		if accept_input:
			get_tree().change_scene_to_file(full_path)
		else: 
			pass
	else: 
		pass
