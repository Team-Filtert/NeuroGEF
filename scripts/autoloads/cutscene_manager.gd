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

func get_character_node(path: String) -> CharacterBase:
	match path:
		"player":
			return PartyManager.overworld_party[0]
		"pm1":
			return PartyManager.overworld_party[1]
		"pm2":
			return PartyManager.overworld_party[2]
		_:
			return get_node(path)

func toggle_mode(npc_path: String, mode_name: String) -> void:
	var npc: NpcTemplateBase = get_node(npc_path)
	npc.toggle_mode(mode_name)

func animate(character_path: String, animation_name: String, is_loop: bool = false) -> void:
	var character: CharacterBase = get_character_node(character_path)
	character.animate(animation_name, is_loop)
	if not is_loop:
		await character.done_animation
		done_action.emit(character.name)

func move(character_path: String, direction: DirectionOption, distance: float, speed: float) -> void:
	var character: CharacterBase = get_character_node(character_path)
	character.move(direction, distance, speed)
	await character.done_moving
	done_action.emit(character.name)
