class_name Party
extends RefCounted

var ult_charge: int
var members: Array[PartyMember]


static func from_dict(data: Dictionary) -> Party:
	var party = Party.new()

	party.ult_charge = data["ult_charge"]
	for m in data["members"]:
		party.members.append(PartyMember.from_dict(m))

	return party


func to_dict() -> Dictionary:
	return {
		"ult_charge": ult_charge,
		"members": members.map(func(m): return m.to_dict()),
	}


func add_member(member: PartyMember) -> void:
	if member != null and not members.has(member):
		members.append(member)


func has_member_named(name: String) -> bool:
	var wanted := name.to_lower()
	for member in members:
		if String(member.display_name).to_lower() == wanted:
			return true
	return false
