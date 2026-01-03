extends Control
class_name CombatManager

signal combat_finished

@export var game_manager: GameManager

@export var player_character_markers: Node2D
@export var enemy_character_markers: Node2D

@export var combat_ui: CombatUIManager
@export var turn_processor: TurnProcessor

@export var character_scene: PackedScene

# @export var characters_menu: Control
@export var char_info_ui_scene: PackedScene

@export var debug_enemies: Array[EnemyCharacter]

func clear_character_slots() -> void:
	for marker in player_character_markers.get_children():
		for child in marker.get_children():
			child.queue_free()
	
	for marker in enemy_character_markers.get_children():
		for child in marker.get_children():
			child.queue_free()

func append_character_to_slot(character: CharacterResource, character_marker: Marker2D, is_player: bool) -> Character:
	var character_instance = character_scene.instantiate() as Character
	character_instance.char_name = character.char_name
	if is_player:
		character_instance.player_character_resource = character
	else:
		character_instance.enemy_character_resource = character
	character_instance.is_player = is_player

	character_marker.add_child(character_instance)
	character_instance.position = Vector2.ZERO
	character_instance.combat_ui = combat_ui

	var char_info_instance = char_info_ui_scene.instantiate() as CharacterInfoPanel
	char_info_instance.character = character_instance
	char_info_instance.char_name_label.text = character.char_name
	combat_ui.character_selection_menu.add_child(char_info_instance)

	return character_instance

func init(enemies: Array[EnemyCharacter] = []):
	if enemies.size() == 0:
		enemies = debug_enemies

	var characters: Array[Character] = []

	for i in range(enemies.size()):
		var enemy_resource = enemies[i]
		var enemy = append_character_to_slot(\
			enemy_resource, \
			enemy_character_markers.get_child(i), \
			false \
		)
		characters.append(enemy)

	for i in range(game_manager.party_members.size()):
		var party_member_resource = game_manager.party_members[i]
		var player_character = append_character_to_slot(\
			party_member_resource, \
			player_character_markers.get_child(i), \
			true \
		)
		characters.append(player_character)

	turn_processor.characters = characters
	turn_processor.characters.sort_custom(func(a: Character, b: Character):
		return a.stats.get_speed() - b.stats.get_speed()
	)

	if not turn_processor.is_connected("combat_finished", _on_turn_processor_combat_finished):
		turn_processor.connect("combat_finished", _on_turn_processor_combat_finished)

	turn_processor.init()

func start_combat(enemies: Array[EnemyCharacter] = []):
	get_tree().paused = true
	visible = true
	game_manager.scene_container.visible = false
	combat_ui.visible = true
	init(enemies)

func _on_turn_processor_combat_finished():
	print("CombatManager: Combat finished")
	combat_ui.visible = false
	get_tree().paused = false
	visible = false
	game_manager.scene_container.visible = true
	clear_character_slots()
	combat_finished.emit()

func _ready():
	# for debug
	# init()
	pass
