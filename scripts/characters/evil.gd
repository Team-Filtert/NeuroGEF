extends CharacterBody2D

@export var dialogue_timeline: DialogicTimeline
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interaction_triggered.connect(_on_interaction_triggered)

func _on_interaction_triggered() -> void:
	interactable.enabled = false
	Dialogic.start(dialogue_timeline)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
func _on_timeline_ended() -> void:
	interactable.enabled = true
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
