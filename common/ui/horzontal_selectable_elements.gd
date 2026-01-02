extends HBoxContainer
class_name HorizontalSelectableElements

@export var input_manager: InputComponent

var cur_element: Selectable
var __initialized = false

signal on_selected_element(el: Selectable)
signal on_discarded()

var __is_wait_for_selection = false
var __discarded = false
var __discard_disabled = false

func init(validate_func: Callable = Callable()):
	var all_children = Utils.get_all_children(self)
	var selectable_elements = all_children.filter(func (child): return child is Selectable)

	# Need to know if selectable is valid before setting up neighbors
	for i in range(selectable_elements.size()):
		var cur_selectable = (selectable_elements[i] as Selectable).selectable_node
		if cur_selectable.has_method("init") and validate_func.is_valid():
			cur_selectable.init(validate_func)
	
	selectable_elements = selectable_elements.filter(func (child):
		var sel: Selectable = child as Selectable
		return sel.get_is_valid()
	)
	
	for i in range(selectable_elements.size()):
		var cur_selectable = (selectable_elements[i] as Selectable).selectable_node

		var left_index = (i - 1 + selectable_elements.size()) % selectable_elements.size()
		var right_index = (i + 1) % selectable_elements.size()
		var left_selectable = (selectable_elements[left_index] as Selectable).selectable_node
		var right_selectable = (selectable_elements[right_index] as Selectable).selectable_node

		cur_selectable.focus_neighbor_left = left_selectable.get_path()
		cur_selectable.focus_neighbor_right = right_selectable.get_path()
	
	selectable_elements[0].set_selected(true)
	cur_element = selectable_elements[0]
	__initialized = true

func wait_for_selection():
	__discard_disabled = true
	while not __is_wait_for_selection:
		await get_tree().create_timer(0).timeout
	__is_wait_for_selection = false
	__discard_disabled = false


func wait_for_selection_or_discarded():
	while not (__is_wait_for_selection or __discarded):
		await get_tree().create_timer(0).timeout
	__is_wait_for_selection = false
	
	if __discarded:
		__discarded = false
		return true
	return false


func _process(_delta):
	if not __initialized:
		return

	var dir_input = input_manager.get_directional_input(true)
	var accept_input = input_manager.get_accept_input()
	var cancel_input = input_manager.get_cancel_input()

	if dir_input == Vector2i.LEFT:
		cur_element.set_selected(false)
		cur_element = Selectable.get_selectable_from_children(\
			get_node(cur_element.selectable_node.focus_neighbor_left)\
		)
		cur_element.set_selected(true)
		return
	
	if dir_input == Vector2i.RIGHT:
		cur_element.set_selected(false)
		cur_element = Selectable.get_selectable_from_children(\
			get_node(cur_element.selectable_node.focus_neighbor_right)\
		)
		cur_element.set_selected(true)
		return
	
	if accept_input:
		on_selected_element.emit(cur_element)
		cur_element.set_selected(false)
		__is_wait_for_selection = true
		__initialized = false
		return
	
	if cancel_input and not __discard_disabled:
		on_discarded.emit()
		cur_element.set_selected(false)
		__discarded = true
		__initialized = false
		return
