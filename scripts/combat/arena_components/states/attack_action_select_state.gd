class_name AttackActionSelectState extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var actions: Array[CombatantAction]

	actions.assign(combatant.attack_actions.filter(
		func(action: CombatantAction):
			return action.is_usable(parent.get_current_combatant())
	).map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
