class_name Setup
extends ArenaStateBase

func enter() -> void:
	for i in range(arena.party_data.size() - 1):
		var combatant := Combatant.new()
		combatant.position = arena.party_slots[i].position
		combatant.setup(arena.party_data[i])
		arena.party_scenes.append(combatant)
	
	for i in range(arena.enemy_data.size() - 1):
		var combatant := Combatant.new()
		combatant.position = arena.enemy_slots[i].position
		combatant.setup(arena.enemy_data[i])
		arena.enemy_scenes.append(combatant)
	
	arena.change_state(next_state)
