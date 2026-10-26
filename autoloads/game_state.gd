extends Node

var party: Party = Party.new()
var inventory: Inventory = Inventory.new()
var keys: PersistenceKeys = PersistenceKeys.new()
var quests: QuestManager = QuestManager.new()

var _transition_root: Node


var _state_manager: Node
var state_stack: Array[Node] = []
var current_state : Node
var poped_result: Variant


func init(state_manager: Node, transition_root: Node) -> void:
	_state_manager = state_manager
	_transition_root = transition_root


func push(state_path: String, args = null, render_underlying := false, transition_path := "res://transitions/fade_transition.tscn"):

	# transition
	var transition: BaseTransition = null
	if not transition_path.is_empty():
		var transition_scene := load(transition_path) as PackedScene
		transition = transition_scene.instantiate()
		_transition_root.add_child(transition)
		@warning_ignore("redundant_await")
		await transition.play_in()

	# Hide the top state if not rendering underlaying
	# also make sure the top state is not processed or input is not processed
	if not state_stack.is_empty():
		var top = state_stack.back()
		# Disabling a CanvasItem's process_mode also stops its children, so the
		# player and any NPCs in the suspended scene stop updating and reacting.
		top.process_mode = Node.PROCESS_MODE_DISABLED
		if not render_underlying and top is CanvasItem:
			(top as CanvasItem).hide()

	# Instantiate the new state and add it to the stack
	var scene := load(state_path)
	current_state = scene.instantiate()
	state_stack.push_back(current_state)
	_state_manager.add_child(current_state)
	current_state.enter(args)
	_activate_camera(current_state)

	# Fan out the transition if one was provided
	if transition:
		@warning_ignore("redundant_await")
		await transition.play_out()
		transition.queue_free()

func pop(result = null, transition_path := "res://transitions/fade_transition.tscn"):
	# Fan in the transition if one was provided
	var transition: BaseTransition = null
	if not transition_path.is_empty():
		var transition_scene := load(transition_path) as PackedScene
		transition = transition_scene.instantiate()
		_transition_root.add_child(transition)
		@warning_ignore("redundant_await")
		await transition.play_in()

	# Pop the state from the stack and remove it from the manager
	state_stack.pop_back()
	_state_manager.remove_child(current_state)
	current_state.queue_free()

	# Restore the previous state
	if not state_stack.is_empty():
		var previous_state = state_stack.back()
		previous_state.process_mode = Node.PROCESS_MODE_INHERIT
		if previous_state is CanvasItem:
			(previous_state as CanvasItem).show()
		current_state = previous_state
		# Switch back while the fade covers the screen, so there is no visible pop.
		_activate_camera(previous_state)

	# Fan in the transition if one was provided
	if transition:
		@warning_ignore("redundant_await")
		await transition.play_out()
		transition.queue_free()
	poped_result = result


#region CAMERA

## Makes the first [Camera2D] found under [param state] current. Called while a
## transition covers the screen (after [code]play_in[/code] / before
## [code]play_out[/code]), so switching between the level and battle cameras is
## never visible. A state without a camera leaves the current one alone.
func _activate_camera(state: Node) -> void:
	var camera := _find_camera(state)
	if camera != null:
		camera.make_current()


func _find_camera(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		var found := _find_camera(child)
		if found != null:
			return found
	return null

#endregion
