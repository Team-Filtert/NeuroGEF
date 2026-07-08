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
	# NOTE: "player" resolves to a follower slot, not PlayerManager's Player -
	# the new Player class doesn't implement animate()/move()/done_animation,
	# so old-style scripted cutscenes can't drive it. Only usable once a
	# CharacterBase-based follower has joined via PartyManager.add_member.
	var lower_character_name = character_name.to_lower()
	match lower_character_name:
		"player":
			return PartyManager.overworld_party[0]
		"pm1":
			return PartyManager.overworld_party[1]
		"pm2":
			return PartyManager.overworld_party[2]
		_:
			return LevelManager._current_level.get_node(character_name)

func toggle_mode(npc_path: String, mode_name: String) -> void:
	var npc: NpcTemplateBase = get_node(npc_path)
	npc.toggle_mode(mode_name)

func animate(character_name: String, animation_name: String, is_loop: bool = false) -> void:
	var character: CharacterBase = get_character_node(character_name)
	character.animate(animation_name, is_loop)
	if not is_loop:
		await character.done_animation
		done_action.emit(character_name)

func move(character_name: String, direction: DirectionOption, distance: float, speed: float) -> void:
	var character: CharacterBase = get_character_node(character_name)
	character.move(direction, distance, speed)
	await character.done_moving
	done_action.emit(character_name)

func move_cam_to(pos: Vector2, secs: float):
	CameraManager.move_to(pos, secs)
	await CameraManager.done_moving
	done_action.emit("Cam")

func move_cam_by(vect: Vector2, secs: float):
	CameraManager.move_by(vect, secs)
	await CameraManager.done_moving
	done_action.emit("Cam")
