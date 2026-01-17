extends Node2D
class_name SceneManager

@export var level_scenes: Dictionary[String, PackedScene]

var current_scene_node: Node2D = null

@export var starting_level_name: String = "Level1"

func _ready() -> void:
	GlobalManager.set_scene_manager(self)
	load_level(starting_level_name)

func load_level(level_name: String, position_to_place_player: Vector2 = Vector2.ZERO) -> void:
	if not level_scenes.has(level_name):
		push_error("Level not found: %s" % level_name)
		return
	
	if current_scene_node:
		current_scene_node.queue_free()
		await current_scene_node.tree_exited

	current_scene_node = level_scenes[level_name].instantiate()

	self.add_child(current_scene_node)

	if position_to_place_player != Vector2.ZERO:
		var player = GlobalManager.get_player()
		if player:
			player.position = position_to_place_player