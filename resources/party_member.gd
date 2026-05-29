class_name PartyMember
extends Resource

@export var display_name: String

static func from_dict(data: Dictionary) -> PartyMember:
	var party_member := PartyMember.new()

	party_member.display_name = data["display_name"]

	return party_member

func to_dict() -> Dictionary:
	return {
		"display_name": display_name
	}
