extends Node

var combat_layer: CanvasLayer
var arena: ArenaComponent
var transition_effect: BaseTransition
var _transition_layer: CanvasLayer

var is_in_combat: bool = false

func _ready() -> void:
	combat_layer = CanvasLayer.new()
	combat_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	combat_layer.visible = false
	add_child(combat_layer)

	var arena_scene: Node2D = preload("res://combat/arena.tscn").instantiate()
	combat_layer.add_child(arena_scene)
	arena = arena_scene.get_node("ArenaComponent")

	_transition_layer = CanvasLayer.new()
	_transition_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_transition_layer.layer = 100
	add_child(_transition_layer)
	transition_effect = preload("res://transitions/fade_transition.tscn").instantiate()
	_transition_layer.add_child(transition_effect)

func start_combat(enemies: Array[CombatantData], music: AudioStream = null) -> void:
	is_in_combat = true
	if music == null:
		AudioManager.change_music(AudioManager.MusicMode.COMBAT)
	else:
		AudioManager.change_music(AudioManager.MusicMode.CUSTOM, music)

	get_tree().paused = true

	await transition_effect.play_in()

	combat_layer.show()

	arena.setup_battle(enemies)
	arena.battle_ended.connect(_on_battle_ended)

	await transition_effect.play_out()

func _on_battle_ended() -> void:
	AudioManager.change_music(AudioManager.MusicMode.OVERWORLD)

	await transition_effect.play_in()
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
		LevelUpManager.level_up_layer.show()
		await transition_effect.play_out()
		await LevelUpManager.done_leveling_up
		await transition_effect.play_in()
		LevelUpManager.level_up_layer.hide()

	get_tree().paused = false
	await transition_effect.play_out()
