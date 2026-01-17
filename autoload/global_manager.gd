extends Node

var gameManager: GameManager = null
var sceneManager: SceneManager = null
var player: PlayerCharacter = null

func get_game_manager() -> GameManager:
	return gameManager

func set_game_manager(manager: GameManager) -> void:
	gameManager = manager

func get_scene_manager() -> SceneManager:
	return sceneManager

func set_scene_manager(manager: SceneManager) -> void:
	sceneManager = manager

func get_player() -> PlayerCharacter:
	return player

func set_player(player_character: PlayerCharacter) -> void:
	player = player_character
