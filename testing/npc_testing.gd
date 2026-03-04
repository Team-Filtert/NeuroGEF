extends Node2D

func _ready() -> void:
	var vedal: NpcStandardTemplate = $NpcStandardTemplate2
	var evil: NpcStandardTemplate = $NpcStandardTemplate
	
	vedal.move(vedal.DirectionOption.DOWN, 50, 20)
	print("start")
	await vedal.done_moving
	print("done")
	vedal.move(vedal.DirectionOption.RIGHT, 50, 20)
	
	evil.start_loop("NpcLoop")
