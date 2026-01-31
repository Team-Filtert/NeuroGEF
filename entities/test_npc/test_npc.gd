extends CharacterBody2D

@export var timeline: DialogicTimeline
@onready var interactable: SignalInteractable = $Interactable

func _ready() -> void:
	interactable.interaction_triggered.connect(_on_interaction_triggered)
	
func _on_interaction_triggered() -> void:
	if not timeline:
		return

	interactable.enabled = false
	Dialogic.start(timeline)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_ended() -> void:
	interactable.enabled = true
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
