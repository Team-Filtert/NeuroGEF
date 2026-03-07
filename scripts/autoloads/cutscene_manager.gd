#yes this file is necessary
#I can't figure out how to access the tree from a dailogic event
extends Node

signal done_action(node_name: StringName)

enum DirectionOption {UP, DOWN, LEFT, RIGHT}

#TODO: replace path when finalized
@onready var player: CharacterBase = $/root/Root/Home/Player

var direction_str_int: Dictionary[String, int] = {
	"up": 0,
	"down": 1,
	"left": 2,
	"right": 3
}

func toggle_follow(npc_path: String):
	var npc: NpcStandardTemplate = get_node(npc_path)
	npc.toggle_follow()

func toggle_loop(npc_path: String, loop_name: String):
	var npc: NpcStandardTemplate = get_node(npc_path)
	npc.toggle_loop(loop_name)

func animate(character_path: String, animation_name: String, is_loop: bool):
	var character: CharacterBase = player if character_path == "player" else get_node(character_path)
	character.animate(animation_name, is_loop)
	if not is_loop:
		await character.done_animation
		done_action.emit(character.name)

func move(character_path: String, direction: DirectionOption, distance: float, speed: float):
	var character: CharacterBase = player if character_path == "player" else get_node(character_path)
	character.move(direction, distance, speed)
	await character.done_moving
	done_action.emit(character.name)
