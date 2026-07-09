class_name PartyState
extends RefCounted

var ult_charge: int
var members: Array[PartyMemberState]

static func from_dict(data: Dictionary) -> PartyState:
	var party = PartyState.new()
	
	party.ult_charge = data["ult_charge"]
	for m in data["members"]:
		party.members.append(PartyMemberState.from_dict(m))
	
	return party
	
func to_dict() -> Dictionary:
	return {
		"ult_charge": ult_charge,
		"members": members.map(func(m): return m.to_dict()),
	}
