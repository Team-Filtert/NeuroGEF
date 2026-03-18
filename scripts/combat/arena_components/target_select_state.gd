class_name TargetSelectState extends ArenaStateBase

@export var action_selection_state: ArenaStateBase
@export var action_group_selection_state: ArenaStateBase
@export var enemy_turn_state: ArenaStateBase

var action: CombatantAction

func enter():
	action = parent.pending_action
	parent.pending_action = null
	parent.target_indicator.visible = true
	_select_target()

func exit() -> void:
	parent.target_indicator.visible = false

func _select_target() -> void:
	var alive_enemies = parent.get_alive_enemies()
	var target = await parent.target_indicator.wait_for_target_selection(alive_enemies)
	
	if target:
		var packed = parent.PackedAction.new(parent.get_current_combatant(), action)
		packed.submitted_action.target = target
		parent.action_queue.append(packed.submitted_action)
		parent.get_current_combatant().set_selected(false)
		parent.player_actions_submitted += 1
		
		if parent.player_actions_submitted >= parent.get_alive_party().size():
			parent.change_state(enemy_turn_state)
		else:
			parent.get_current_combatant().set_selected(true)
			parent.change_state(action_group_selection_state)
	else:
		parent.change_state(action_selection_state)
