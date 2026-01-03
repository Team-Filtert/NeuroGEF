extends Node2D
class_name CameraFollower


func _process(_delta):
	global_position = get_viewport().get_camera_2d().global_position
