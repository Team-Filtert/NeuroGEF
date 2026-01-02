extends Control
class_name CombatManager

@export var game_manager: GameManager

@export var player_character_markers: Node2D
@export var enemy_character_markers: Node2D

@export var combat_ui: CombatUIManager
@export var turn_processor: TurnProcessor

@export var character_scene: PackedScene

# @export var characters_menu: Control
@export var char_info_ui_scene: PackedScene

@export var debug_enemies: Array[EnemyCharacter]

func init(enemies: Array[EnemyCharacter] = []):
	if enemies.size() == 0:
		enemies = debug_enemies

	var characters: Array[Character] = []

	for i in range(enemies.size()):
		var enemy_resource = enemies[i]
		var character_instance = character_scene.instantiate() as Character
		character_instance.char_name = enemy_resource.char_name
		character_instance.enemy_character_resource = enemy_resource
		character_instance.is_player = false
		character_instance.position = enemy_character_markers.get_child(i).position
		character_instance.combat_ui = combat_ui
		add_child(character_instance)
		characters.append(character_instance)

		var char_info_instance = char_info_ui_scene.instantiate() as CharacterInfoPanel
		char_info_instance.character = character_instance
		char_info_instance.char_name_label.text = enemy_resource.char_name
		combat_ui.character_selection_menu.add_child(char_info_instance)

	for i in range(game_manager.party_members.size()):
		var party_member_resource = game_manager.party_members[i]
		var character_instance = character_scene.instantiate() as Character
		character_instance.char_name = party_member_resource.char_name
		character_instance.player_character_resource = party_member_resource
		character_instance.is_player = true
		character_instance.position = player_character_markers.get_child(i).position
		character_instance.combat_ui = combat_ui
		add_child(character_instance)
		characters.append(character_instance)

		var char_info_instance = char_info_ui_scene.instantiate() as CharacterInfoPanel
		char_info_instance.character = character_instance
		char_info_instance.char_name_label.text = party_member_resource.char_name
		combat_ui.character_selection_menu.add_child(char_info_instance)

	turn_processor.characters = characters
	turn_processor.characters.sort_custom(func(a: Character, b: Character):
		return a.stats.get_speed() - b.stats.get_speed()
	)
	turn_processor.init()

func _ready():
	# for debug
	# init()
	pass
