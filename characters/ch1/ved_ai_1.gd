extends Node2D


@export var timeline: DialogicTimeline

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var beeTree := get_node("BeehaveNode/SequenceComposite/StartTimeline")
	beeTree.timeline = timeline

func _process(delta: float) -> void:
	if global_position.y >= PlayerManager.get_player_position().y:
		z_index = PlayerManager.get_player_z_index() + 1
	else:
		z_index = 0
