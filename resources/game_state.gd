class_name GameState
extends Resource

var current_scene_path: String = ""
var inventory := Inventory.new()
var party := Party.new()
var player_position := Vector2.ZERO

static func from_dict(data: Dictionary) -> GameState:
	var game_state := GameState.new()

	game_state.current_scene_path = data["current_scene_path"]
	game_state.inventory = Inventory.from_dict(data["inventory"])
	game_state.party = Party.from_dict(data["party"])
	game_state.player_position = Vector2(data["player_position"]["x"], data["player_position"]["y"])

	return game_state

func to_dict() -> Dictionary:
	return {
		"current_scene_path": current_scene_path,
		"inventory": inventory.to_dict(),
		"party": party.to_dict(),
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		}
	}
