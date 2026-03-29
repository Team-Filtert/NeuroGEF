class_name AttackActionSelectState extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	# will get actions from combatant somehow
	var actions: Array[CombatantAction] = []
	for i in range(9):
		var action = CombatantAction.new()
		action.display_name = "Attack " + str(i)
		action.type = CombatantActionStorage.Type.ATTACK
		action.source = combatant
		action.process_func = _on_action_selected.bind(action)
		actions.append(action)
	
	return actions
