extends Control
class_name GridSelectableElements

@export var input_manager: InputComponent

@export var column_container: VBoxContainer
@export var row_containers: Array[HBoxContainer]
@export var max_columns: int = 3

var rows: int:
	get:
		return row_containers.size()
var columns: int:
	get:
		if row_containers.size() == 0:
			return 0
		
		row_containers.sort_custom(func(a, b): return b.get_child_count() - a.get_child_count())
		var most_children_row = row_containers[0]
		return most_children_row.get_child_count()

var cur_element: Selectable
var __initialized = false

signal on_selected_element(el: Selectable)
signal on_discarded()
var __is_wait_for_selection = false
var __discarded = false

func init(child_create_func: Callable = Callable()):
	if child_create_func.is_valid():
		for r in range(rows):
			var row_container: HBoxContainer = row_containers[r]
			for c in range(max_columns):
				# get instantiated child node from callable converting row and column numbers to array index
				var index = r * max_columns + c
				var child_node = child_create_func.call(index)
				if child_node:
					row_container.add_child(child_node)
	
	var all_children = Utils.get_all_children(self)
	var selectable_elements = all_children.filter(func (child): return child is Selectable)

	var _columns = columns

	for i in range(selectable_elements.size()):
		var left_index = (i - 1 + selectable_elements.size()) % selectable_elements.size()
		var right_index = (i + 1) % selectable_elements.size()
		var up_index = (i - _columns + selectable_elements.size()) % selectable_elements.size()
		var down_index = (i + _columns) % selectable_elements.size()
		var cur_selectable = (selectable_elements[i] as Selectable).selectable_node
		var left_selectable = (selectable_elements[left_index] as Selectable).selectable_node
		var right_selectable = (selectable_elements[right_index] as Selectable).selectable_node
		var up_selectable = (selectable_elements[up_index] as Selectable).selectable_node
		var down_selectable = (selectable_elements[down_index] as Selectable).selectable_node

		cur_selectable.focus_neighbor_left = left_selectable.get_path()
		cur_selectable.focus_neighbor_right = right_selectable.get_path()
		cur_selectable.focus_neighbor_top = up_selectable.get_path()
		cur_selectable.focus_neighbor_bottom = down_selectable.get_path()

		if cur_selectable.has_method("init"):
			cur_selectable.init()
		
	selectable_elements[0].set_selected(true)
	cur_element = selectable_elements[0]
	__initialized = true

func clear_children():
	for row_container in row_containers:
		var children = row_container.get_children()
		for child in children:
			child.queue_free()

func wait_for_selection():
	while not __is_wait_for_selection:
		await get_tree().create_timer(0).timeout
	__is_wait_for_selection = false

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
	
	if dir_input == Vector2i.UP:
		cur_element.set_selected(false)
		cur_element = Selectable.get_selectable_from_children(\
			get_node(cur_element.selectable_node.focus_neighbor_top)\
		)
		cur_element.set_selected(true)
		return
	
	if dir_input == Vector2i.DOWN:
		cur_element.set_selected(false)
		cur_element = Selectable.get_selectable_from_children(\
			get_node(cur_element.selectable_node.focus_neighbor_bottom)\
		)
		cur_element.set_selected(true)
		return
	
	if accept_input:
		on_selected_element.emit(cur_element)
		cur_element.set_selected(false)
		__is_wait_for_selection = true
		__initialized = false
	
	if cancel_input:
		on_discarded.emit()
		cur_element.set_selected(false)
		__discarded = true
		__initialized = false
	
