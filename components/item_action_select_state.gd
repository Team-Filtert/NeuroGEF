class_name ItemActionSelectState
extends ActionSelectState

func get_combatant_actions(combatant: Combatant):
	var all_actions: Array = []
	
	for consumable in InventoryManager.consumables:
		if consumable.combat_action != null:
			var action := consumable.combat_action.duplicate(true)
			action.item = consumable
			all_actions.append(action)
	
	var actions: Array[CombatantAction]
	actions.assign(all_actions.map(
		func(action: CombatantAction):
			var processed_action = action
			processed_action.source = combatant
			processed_action.process_func = _on_action_selected.bind(action)
			return processed_action
	))
	
	return actions
