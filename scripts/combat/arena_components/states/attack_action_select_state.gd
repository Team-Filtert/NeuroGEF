class_name AttackActionSelectState extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var actions: Array[CombatantAction]

	actions.assign(combatant.attack_actions.map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
