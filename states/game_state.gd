class_name GameState
extends RefCounted

var party := PartyState.new()

static func from_dict(data: Dictionary) -> GameState:
	var game = GameState.new()
	
	game.party = PartyState.from_dict(data["party"])
	
	return game

func to_dict() -> Dictionary:
	return {
		"party": party.to_dict()
	}
