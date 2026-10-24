class_name SaveSettings
extends RefCounted

var is_qte_in_active_mode: bool = true

static func from_dict(data: Dictionary) -> SaveSettings:
	var settings = SaveSettings.new()
	
	settings.is_qte_in_active_mode = data["is_qte_in_active_mode"]
	
	return settings

func to_dict() -> Dictionary:
	return {
		"is_qte_in_active_mode": is_qte_in_active_mode
	}
