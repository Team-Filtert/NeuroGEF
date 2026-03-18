extends MenuHandler
class_name GridMenuHandler

@export var is_cycled: bool = true

var columns: Array[VBoxContainer]
var row_count: int

func _ready() -> void:
	parent = get_parent() as Control

	var children = parent.get_children()
	columns = []
	for child in children:
		if child is VBoxContainer:
			columns.append(child)

	if columns.size() > 0:
		row_count = columns[0].get_children().filter(func(child):
			return child is MenuElement
		).size()

	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	parent.visibility_changed.connect(_on_visibility_changed)
	input_handler = UIInputComponent.new()
	add_child(input_handler)

	get_items().map(func(item: MenuElement):
		if item:item.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	)

## Getting menu items from handled menu
func get_items() -> Array[MenuElement]:
	var items: Array[MenuElement] = []
	for column in columns:
		for row_ndx in row_count:
			# pushing null to preserve grid structure
			# to simplify focus navigation logic

			if row_ndx >= column.get_child_count():
				items.append(null)
				continue

			var row = column.get_child(row_ndx)
			if row is MenuElement:
				items.append(row)
			else:
				items.append(null)
	return items

#region Grid navigation logic

func _get_item_at_position(column: int, row: int) -> MenuElement:
	if column < 0:
		if is_cycled:
			column += columns.size()
		else:
			return null
	elif column >= columns.size():
		if is_cycled:
			column = 0
		else:
			return null

	if row < 0:
		if is_cycled:
			row += row_count
		else:
			return null
	elif row >= row_count:
		if is_cycled:
			row = 0
		else:
			return null

	var index = _grid_position_to_arr_index(column, row)
	var items = get_items()
	if index < items.size():
		return items[index]
	return null

func _get_item_upper(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column, row - 1)
	if not item:
		return _get_item_upper(column, row - 1)
	return item

func _get_item_lower(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column, row + 1)
	if not item:
		return _get_item_lower(column, row + 1)
	return item

func _get_item_left(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column - 1, row)
	if not item:
		return _get_item_left(column - 1, row)
	return item

func _get_item_right(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column + 1, row)
	if not item:
		return _get_item_right(column + 1, row)
	return item

func _arr_indxes_to_grid_position(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var column = index / row_count
	var row = index % row_count
	return Vector2i(column, row)

func _grid_position_to_arr_index(column: int, row: int) -> int:
	return column * row_count + row

#endregion

# func get_item_at_index(index: int) -> MenuElement:
# 	var pos = _arr_indxes_to_grid_position(index)
# 	return _get_item_on_position(pos.x, pos.y)

func clear_items() -> void:
	for column in columns:
		for row_ndx in row_count:
			var item = _get_item_at_position(columns.find(column), row_ndx)
			if item:
				item.queue_free()

func add_item(item: MenuElement) -> void:
	var items_size = get_items().filter(func(i): return i != null).size()
	var pos = _arr_indxes_to_grid_position(items_size)
	if pos.x >= columns.size():
		printerr("No more columns to add items to")
		return
	elif pos.y >= row_count:
		printerr("No more rows to add items to")
		return
	columns[pos.x].add_child(item)

func create_items(actions: Array[CombatantAction], on_item_pressed: Callable) -> void:
	for action in actions:
		var item = MenuElement.create(action.display_name, self, action)
		item.pressed.connect(on_item_pressed.bind(action))
		add_item(item)

# Implementation for grid layout out of columns as VBoxContainers
# while main container is HBoxContainer
func build_navigation() -> void:
	var items = get_items()
	for i in items.size():
		var item: MenuElement = items[i]

		if item == null:
			continue
		
		item.focus_mode = Control.FOCUS_ALL
		item.parent_menu = self

		var pos: Vector2i = _arr_indxes_to_grid_position(i)
		var column = pos.x
		var row = pos.y
		
		var left_item = _get_item_left(column, row)
		var right_item = _get_item_right(column, row)
		var top_item = _get_item_upper(column, row)
		var bottom_item = _get_item_lower(column, row)

		item.focus_neighbor_left = left_item.get_path() if left_item else item.get_path()
		item.focus_neighbor_right = right_item.get_path() if right_item else item.get_path()
		item.focus_neighbor_top = top_item.get_path() if top_item else item.get_path()
		item.focus_neighbor_bottom = bottom_item.get_path() if bottom_item else item.get_path()

		if i == 0:
			item.grab_focus()
	
