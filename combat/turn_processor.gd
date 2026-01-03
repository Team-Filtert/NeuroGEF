extends Node2D
class_name TurnProcessor

signal combat_finished

@export var characters: Array[Character]
@export var turn_timer: Timer

var turn_queue: Array[Character]

func init():
	turn_queue.assign(characters)
	process_turn_cycled()

func process_turn_cycled():
	while turn_queue.size() > 0:
		await turn_timer.timeout

		var current_character = turn_queue.pop_front()
		var char_code_result = await current_character.turn_process()
		# await current_character.turn_end
		print("current character: " + str(current_character.char_name) + " ended turn")

		var result = process_character_turn_end()

		if result != 0 or char_code_result == 1:
			combat_finished.emit()
			return
	
	process_turn_end()

func prepare_turn_queue():
	for character in characters:
		turn_queue.push_back(character)

func process_character_turn_end():
	var player_characters = characters.filter(func(character: Character): return character.is_player)
	var enemy_characters = characters.filter(func(character: Character): return not character.is_player)

	if player_characters.all(func(character: Character): return character.stats.get_health() == 0):
		print("Player lost")
		return 1
	
	if enemy_characters.all(func(character: Character): return character.stats.get_health() == 0):
		print("Player won")
		return 2
	
	return 0

func process_turn_end():
	prepare_turn_queue()
	
	process_turn_cycled()
