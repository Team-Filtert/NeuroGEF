extends Node

var party: Party
var inventory: Inventory
var keys: PersistenceKeys = PersistenceKeys.new()
var quests: QuestManager = QuestManager.new()

var _transition_root: Node


var _state_manager: Node
var state_stack: Array[Node] = []
var current_state : Node

func init(state_manager: Node, transition_root: Node) -> void:
	_state_manager = state_manager
	_transition_root = transition_root

func push(state_path: String, args = null, render_underlying := false, transition_path := "res://transitions/fade_transition.tscn"):
	var transition: BaseTransition = null
	if not transition_path.is_empty():
		var transition_scene := load(transition_path) as PackedScene
		transition = transition_scene.instantiate()
		_transition_root.add_child(transition)
		@warning_ignore("redundant_await")
		await transition.play_in()

	if not state_stack.is_empty():
		var top = state_stack.back()
		top.set_process(false)
		top.set_process_input(false)
		if not render_underlying:
			top.hide()
	
	var scene := load(state_path)
	current_state = scene.instantiate()
	state_stack.push_back(current_state)
	_state_manager.add_child(current_state)
	current_state.enter(args)
	if transition:
		@warning_ignore("redundant_await")
		await transition.play_out()
		transition.queue_free()

func pop(result = null):
	state_stack.pop_back()
	_state_manager.remove_child(current_state)
	current_state.queue_free()
	if not state_stack.is_empty():
		var previous_state = state_stack.back()
		previous_state.show()
		previous_state.set_process(true)
		previous_state.set_process_input(true)
		current_state = previous_state
	return result

func _ready() -> void:
	print("current stack:", state_stack)
# func _process(delta) -> void:
# 	print("current stack:", state_stack)
