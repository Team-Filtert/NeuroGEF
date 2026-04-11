extends Node

@onready var combat_layer: CanvasLayer = $/root/Root/CombatLayer
@onready var arena: ArenaComponent = $/root/Root/CombatLayer/Arena/ArenaComponent
@onready var music_player: AudioStreamPlayer = $/root/Root/MusicPlayer
@onready var transition_effect: Transition = $/root/Root/TransitionLayer/Transition
#@onready var transition_effect: Transition = $UIlayer/Transition
var is_in_combat: bool = false

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

	get_tree().paused = false
	combat_layer.hide()
	arena.cleanup_battle()
	arena.battle_ended.disconnect(_on_battle_ended)

	await transition_effect.transition_out()
