#yes this file is necessary
#I can't figure out how to access the tree from a dailogic event
extends Node

signal done_action(node_name: StringName)

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

var direction_str_int: Dictionary[String, int] = {
	"up": 0,
	"down": 1,
	"left": 2,
	"right": 3
}

func start_cutscene(timeline: DialogicTimeline):
	if Dialogic.current_timeline == null:
		Dialogic.start(timeline)

func get_character_node(character_name: String) -> CharacterBase:
	var lower_character_name = character_name.to_lower()
	match lower_character_name:
		"player":
			return GameManager.party_manager.overworld_party[0]
		"pm1":
			return GameManager.party_manager.overworld_party[1]
		"pm2":
			return GameManager.party_manager.overworld_party[2]
		_:
			var cur_scene_container = GameManager.scene_manager.scene_container_node
			var level := cur_scene_container.get_child(0).name
			return get_node(str(cur_scene_container.get_path()) + "/" + level + "/" + character_name)

func toggle_mode(npc_path: String, mode_name: String) -> void:
	var npc: NpcTemplateBase = get_node(npc_path)
	npc.toggle_mode(mode_name)

func animate(character_name: String, animation_name: String, is_loop: bool = false) -> void:
	var character: CharacterBase = get_character_node(character_name)
	character.animate(animation_name, is_loop)
	if not is_loop:
		await character.done_animation
		done_action.emit(character.name)

func move(character_name: String, direction: DirectionOption, distance: float, speed: float) -> void:
	var character: CharacterBase = get_character_node(character_name)
	character.move(direction, distance, speed)
	await character.done_moving
	done_action.emit(character.name)
