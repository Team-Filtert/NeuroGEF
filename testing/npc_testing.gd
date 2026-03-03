extends Node2D

func _ready() -> void:
	var vedal: NpcStandardTemplate = $NpcStandardTemplate2
	vedal.stop_following()
	vedal.move(vedal.DirectionOption.DOWN, 50, 20)
	await vedal.done_moving
	vedal.turn(vedal.DirectionOption.RIGHT)
