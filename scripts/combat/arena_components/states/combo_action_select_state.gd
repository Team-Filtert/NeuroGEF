class_name ComboActionSelectState extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var all_actions: Array[CombatantComboAction] = parent.combo_actions.duplicate(true)
	
	var actions: Array[CombatantAction]
	actions.assign(all_actions.filter(
		func(action: CombatantComboAction):
			return action.is_accessible(parent.party)
	).map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.source = combatant
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
