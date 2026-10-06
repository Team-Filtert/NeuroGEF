extends Node

## Player-facing settings. For now this only holds the combat timing mode, but it
## is the single place for anything toggleable from an options menu.
##
## Active mode  -> the player drives combat timing with a QTE.
## Relaxed mode -> no QTE; outcomes are rolled from the accuracy stat instead.

enum QTEMode {
	ACTIVE,
	RELAXED,
}

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "combat"

signal qte_mode_changed(mode: QTEMode)

var qte_mode: QTEMode = QTEMode.ACTIVE:
	set(value):
		if qte_mode == value:
			return
		qte_mode = value
		qte_mode_changed.emit(value)


func _ready() -> void:
	load_settings()


func is_active_mode() -> bool:
	return qte_mode == QTEMode.ACTIVE


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	qte_mode = config.get_value(SECTION, "qte_mode", QTEMode.ACTIVE)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, "qte_mode", qte_mode)
	config.save(SETTINGS_PATH)
