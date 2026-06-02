class_name CombatantComboAction
extends CombatantAction

## With this the characters names should be found
## in runtimme
@export var required_characters_names: Array[String]

func is_accessible_combo(party: Array[Combatant]) -> bool:
	# check if party has all combatants
	# with reuired names,
	# names are converted to lower case
	return required_characters_names.all(
		func(char_name: String):
			return party.map(
				func(combatant: Combatant):
					return combatant.display_name.to_lower()
			).has(char_name.to_lower())
	)
