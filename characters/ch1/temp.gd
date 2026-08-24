extends CharacterBody2D

@export var timeline: DialogicTimeline
@export var quest: Quest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var beeTree := get_node("BeehaveTree/SequenceComposite/StartTimeline")
	var beeQuest := get_node("BeehaveTree/SequenceComposite/AddQuest")
	beeTree.timeline = timeline
	beeQuest.quest = quest

func _process(delta: float) -> void:
	if global_position.y >= PlayerManager.get_player_position().y:
		z_index = PlayerManager.get_player_z_index() + 1
	else:
		z_index = 0
