extends Node
class_name SceneTransitionComponent


@export var transition_id : String
@export var transition_to_id : String
@export var to_scene_name: String
@export var collision_area: Area2D
@export var scene_directory: String
@export var dir : int


func _ready():
	collision_area.body_entered.connect(enter_scene)
	dir = self.get_parent().dir
	EventBus.scene_entered.emit(self)

func enter_scene(body: Node2D):
	# reading SceneManager.transition_time_out is bad and will be refactored later
	if body.is_in_group("player") and !SceneManager.transition_time_out:
		EventBus.change_scene_triggered.emit(to_scene_name,scene_directory, self)
