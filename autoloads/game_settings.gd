extends Node

## Player-facing settings. For now this only holds the combat timing mode, but it
## is the single place for anything toggleable from an options menu.
##
## Active mode  -> the player drives combat timing with a QTE.
## Relaxed mode -> no QTE; outcomes are rolled from the accuracy stat instead.


const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "combat"

var save_settings: SaveSettings = SaveSettings.new()

func is_active_mode() -> bool:
	return save_settings.is_qte_in_active_mode
