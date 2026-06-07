class_name NpcActionTurn
extends NpcActionBase

@export var template: NpcTemplateBase
@export var direction: CutsceneManager.DirectionOption = CutsceneManager.DirectionOption.UP

var animation: StringName

func _ready() -> void:
	match direction:
		CutsceneManager.DirectionOption.UP:
			animation = "idle_up"
		CutsceneManager.DirectionOption.DOWN:
			animation = "idle_down"
		CutsceneManager.DirectionOption.LEFT:
			animation = "idle_left"
		CutsceneManager.DirectionOption.RIGHT:
			animation = "idle_right"

func _preform_action():
	template.animate(animation)
