extends Node

@onready var combat_layer: CanvasLayer = $/root/Root/CombatLayer
@onready var arena: ArenaComponent = $/root/Root/CombatLayer/Arena/ArenaComponent
@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer
@onready var transition_effect: Transition = $/root/Root/TransitionLayer/Transition
@onready var level_up_layer: CanvasLayer = $/root/Root/LevelUpLayer
#@onready var transition_effect: Transition = $UIlayer/Transition
var is_in_combat: bool = false

func _ready():
	EventBus.combat_triggered.connect(start_combat)

func start_combat(enemies: Array[CombatantData], music: AudioStream = null) -> void:
	is_in_combat = true
	if music == null:
		AudioManager.change_music(AudioManager.MusicMode.COMBAT)
	else:
		AudioManager.change_music(AudioManager.MusicMode.CUSTOM, music)
	
	get_tree().paused = true

	await transition_effect.transition_in()
	
	combat_layer.show()
	
	arena.setup_battle(enemies)
	arena.battle_ended.connect(_on_battle_ended)

	await transition_effect.transition_out()
	
func _on_battle_ended() -> void:
	AudioManager.change_music(AudioManager.MusicMode.OVERWORLD)

	await transition_effect.transition_in()
	is_in_combat = false
	
	combat_layer.hide()
	arena.cleanup_battle()
	arena.battle_ended.disconnect(_on_battle_ended)
	
	var leveling_up_characters: Array[CombatantData] = []
	for character in PartyManager.combat_party:
		if character.xp >= LevelUpManager.get_xp_requirement(character.level):
			leveling_up_characters.append(character)
	
	if leveling_up_characters.size() > 0:
		LevelUpManager.start_level_up(leveling_up_characters)
		level_up_layer.show()
		await transition_effect.transition_out()
		await LevelUpManager.done_leveling_up
		await transition_effect.transition_in()
		level_up_layer.hide()
	
	get_tree().paused = false
	await transition_effect.transition_out()
