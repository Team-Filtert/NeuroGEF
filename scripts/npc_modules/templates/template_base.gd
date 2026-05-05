class_name NpcTemplateBase
extends CharacterBase

var modes: Array[NpcModeBase] = []

func setup() -> void:
	connect_character_nodes()
	
	for node in get_children():
		if node is NpcModeBase:
			modes.push_back(node)
	
	for node in get_parent().get_children():
		if node is LevelAudioData:
			node.level_sfx_players[self.name] = audio_player

func toggle_mode(mode_name: StringName) -> void:
	var mode: NpcModeBase = modes.filter(func(node): return node.name == mode_name).front()
	if mode == null:
		push_error("Mode node ", mode_name,  " is missing")
	elif mode.is_active:
		mode._activate()
	else:
		mode._deactivate()
