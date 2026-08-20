class_name StartTimeline
extends ActionLeaf

@export var timeline: DialogicTimeline
@export var key: String

var has_started_timeline := false
var key_set := false

func  tick(actor: Node, blackboard: Blackboard) -> int:
	if GameState.has_key(key):
		key_set = GameState.get_key(key) 
	else:
		key_set = false
	if Dialogic.current_timeline == null and !key_set :
		if has_started_timeline:
			has_started_timeline = false
			return SUCCESS
		else :
			GameState.add_key(key, true)
			print(GameState.get_keys())
			Dialogic.start(timeline)
			has_started_timeline = true
			return RUNNING
	else:
		if has_started_timeline:
			return RUNNING
		else:
			return FAILURE
