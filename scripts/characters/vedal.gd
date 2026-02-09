extends CharacterBody2D

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interaction_triggered.connect(_on_interaction_triggered)

func _on_interaction_triggered() -> void:
	CombatManager.start_combat()