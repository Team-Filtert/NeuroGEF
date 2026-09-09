class_name StartTimeline
extends ActionLeaf

@export var timeline: DialogicTimeline
@export var key: String

var has_started_timeline := false
var key_set := false

func  tick(actor: Node, blackboard: Blackboard) -> int:
	if GameState.keys.has(key):
		key_set = GameState.keys.value(key) 
	else:
		key_set = false
	if Dialogic.current_timeline == null and !key_set :
		if has_started_timeline:
			has_started_timeline = false
			return SUCCESS
		else :
			GameState.keys.add(key, true)
			print(GameState.keys.get_all())
			Dialogic.start(timeline)
			has_started_timeline = true
			return RUNNING
	else:
		if has_started_timeline:
			return RUNNING
		else:
			return FAILURE
