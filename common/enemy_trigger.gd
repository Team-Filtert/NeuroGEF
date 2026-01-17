extends Node2D

@export var enemies_resources: Array[EnemyCharacter]

@onready var interactable: SignalInteractable = $SignalInteractable

func _ready() -> void:
	interactable.interaction_available.connect(_on_interactable_interaction_triggered)
	
func _on_interactable_interaction_triggered():
	GlobalManager.get_game_manager().combat_manager.start_combat(enemies_resources)
	await GlobalManager.get_game_manager().combat_manager.combat_finished
