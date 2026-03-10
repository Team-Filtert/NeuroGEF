class_name NpcActionMove
extends NpcActionBase

@export var template: NpcStandardTemplate
@export var direction: CutsceneManager.DirectionOption = CutsceneManager.DirectionOption.UP
@export var distance: float = 50
@export var speed: float = 20

func _ready() -> void:
	wait = true
	
func _preform_action() -> void:
	template.move(direction, distance, speed)
	await template.done_moving
	done_action.emit()
