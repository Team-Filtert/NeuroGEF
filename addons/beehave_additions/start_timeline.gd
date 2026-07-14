class_name StartTimeline
extends ActionLeaf

@export var timeline: DialogicTimeline

var has_started_timeline := false

func  tick(actor: Node, blackboard: Blackboard) -> int:
	if Dialogic.current_timeline == null:
		if has_started_timeline:
			has_started_timeline = false
			return SUCCESS
		else :
			GameState.add_key("lol", "baum")
			print(GameState.get_keys())
			Dialogic.start(timeline)
			has_started_timeline = true
			return RUNNING
	else:
		if has_started_timeline:
			return RUNNING
		else:
			return FAILURE
