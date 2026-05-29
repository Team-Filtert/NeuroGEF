class_name Party
extends Resource

var members: Array[PartyMember] = []

static func from_dict(data: Dictionary) -> Party:
	var party := Party.new()

	for m in data["members"]:
		party.members.append(PartyMember.from_dict(m))

	return party

func to_dict() -> Dictionary:
	return {
		"members": members.map(func(m): return m.to_dict())
	}