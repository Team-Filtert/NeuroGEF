class_name ComboActionSelectState
extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var all_actions: Array[CombatantComboAction] = []
	
	for action in arena.combo_actions:
		all_actions.append(action.duplicate(true))
	
	var actions: Array[CombatantAction]
	
	actions.assign(all_actions.filter(
		func(action: CombatantComboAction):
			var is_accessible := action.is_accessible(parent.get_current_combatant())
			var is_accessible_combo := action.is_accessible_combo(parent.party)
			return is_accessible and is_accessible_combo
	).map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.source = combatant
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
