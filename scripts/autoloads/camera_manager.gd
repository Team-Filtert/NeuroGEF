extends Node

signal done_moving

@onready var pcam: PhantomCamera2D = $/root/Root/PhantomCamera2D

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func follow_player():
	pcam.follow_target = PartyManager.overworld_party[0]
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
	print("end")
	follow_player()
