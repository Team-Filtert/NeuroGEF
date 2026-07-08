extends Node

signal done_moving

var pcam: PhantomCamera2D

func _ready() -> void:
	var cam := Camera2D.new()
	cam.top_level = true
	add_child(cam)

	var host := PhantomCameraHost.new()
	host.process_priority = 300
	host.process_physics_priority = 300
	cam.add_child(host)

	pcam = PhantomCamera2D.new()
	pcam.top_level = true
	pcam.follow_mode = PhantomCamera2D.FollowMode.GLUED
	pcam.tween_resource = PhantomCameraTween.new()
	pcam.tween_on_load = false
	add_child(pcam)

	Dialogic.timeline_ended.connect(_on_timeline_ended)

func follow_player():
	if is_instance_valid(PlayerManager._player):
		pcam.follow_target = PlayerManager._player
	pcam.follow_mode = pcam.FollowMode.GLUED

func move_to(pos: Vector2, secs: float):
	pcam.follow_mode = pcam.FollowMode.NONE
	var tween := pcam.create_tween()
	tween.tween_property(pcam, "position", pos, secs)
	await tween.finished
	done_moving.emit()

func move_by(vect: Vector2, secs: float):
	move_to(vect + pcam.position, secs)

func _on_timeline_ended():
	follow_player()
