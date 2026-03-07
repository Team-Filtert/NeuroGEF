extends CharacterBody2D

@onready var interactable: Interactable = $Interactable

@export var combat_data_debug: CombatantData

func _ready() -> void:
	interactable.interaction_triggered.connect(_on_interaction_triggered)

func _on_interaction_triggered() -> void:
	CombatManager.start_combat([combat_data_debug, combat_data_debug, combat_data_debug])