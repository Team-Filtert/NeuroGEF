class_name ActionSelectState extends ArenaStateBase

@export var menu_handler: MenuHandler
@export var prev_state: ArenaStateBase
@export var next_state: ArenaStateBase

func enter():
	menu_handler.parent.visible = true
	menu_handler.callable_unfocus_event = func():
		parent.change_state(prev_state)

	menu_handler.configure_focus(true)

func exit():
	menu_handler.parent.visible = false
	menu_handler.callable_unfocus_event = Callable()


func setup_menu_for_current_character():
	menu_handler.parent.visible = false

	var cur_combatant = parent.get_current_combatant()
	var actions: Array[CombatantAction] = get_combatant_actions(cur_combatant)

	menu_handler.clear_items()
	await get_tree().create_timer(0.05).timeout
	menu_handler.create_items(actions, func(action: CombatantAction):
		action.process_func.call()
	)

# virtual method
func get_combatant_actions(_combatant: Combatant) -> Array[CombatantAction]:
	return []

func _on_action_selected(action: CombatantAction):
	if action is CombatantItemAction:
		action.destroy_item()
	parent.pending_action = action
	parent.change_state(next_state)
