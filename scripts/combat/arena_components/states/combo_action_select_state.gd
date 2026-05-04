class_name ComboActionSelectState
extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var all_actions: Array[CombatantComboAction] = []
	
	for action in parent.combo_actions:
		all_actions.append(action.duplicate(true))
	
	var actions: Array[CombatantAction]
	
	actions.assign(all_actions.filter(
		func(action: CombatantComboAction):
			var is_accessible := action.is_accessible(parent.party)
			var is_usable := action.is_usable(parent.get_current_combatant())
			return is_accessible and is_usable
	).map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.source = combatant
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
