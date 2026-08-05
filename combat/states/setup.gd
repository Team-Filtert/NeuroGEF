class_name Setup
extends ArenaStateBase

func enter() -> void:
	var combatant_scene := preload("res://combat/combatant.tscn")
	
	for i in range(arena.party_data.size() - 1):
		var combatant: Combatant = combatant_scene.instantiate()
		combatant.setup(arena.party_data[i], arena.party_slots[i].position)
		arena.party_scenes.append(combatant)
	
	for i in range(arena.enemy_data.size() - 1):
		var combatant: Combatant = combatant_scene.instantiate()
		combatant.setup(arena.enemy_data[i], arena.enemy_slots[i].position)
		arena.enemy_scenes.append(combatant)
	
	arena.change_state(next_state)
