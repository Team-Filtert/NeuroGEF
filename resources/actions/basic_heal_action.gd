class_name BasicHealAction
extends CombatantAction

static func create_action(new_name: String, new_source: Combatant) -> BasicAttackAction:
	var action = BasicAttackAction.new()
	action.display_name = new_name
	action.type = Type.HEAL
	action.source = new_source
	return action
