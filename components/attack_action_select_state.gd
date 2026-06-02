class_name AttackActionSelectState
extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var actions: Array[CombatantAction]

	actions.assign(combatant.attack_actions.filter(
		func(action: CombatantAction):
			if action is CombatantUltAction:
				var ult_action: CombatantUltAction = action
				var is_accessible := ult_action.is_accessible(parent.get_current_combatant())
				var is_accessible_ult := ult_action.is_accessible_ult(arena)
				return is_accessible and is_accessible_ult
			else:
				return action.is_accessible(parent.get_current_combatant())
	).map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))

	return actions
