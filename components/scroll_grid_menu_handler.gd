extends MenuHandler
class_name ScrollGridMenuHandler

@export var is_cycled: bool = true
@export var view_hight: int = 2
# @export var scroll: ScrollContainer
var scroll: ScrollContainer
var vbox : Control


var rows: Array[HBoxContainer]
var column_count: int


func _ready() -> void:
	parent = get_parent() as Control
	scroll = parent
	vbox = get_vbox(parent) as Control
	

	var children = vbox.get_children()
	rows = []
	for child in children:
		if child is HBoxContainer:
			rows.append(child)

	if rows.size() > 0:
		column_count = rows[0].get_children().filter(func(child):
			return child is MenuElement
		).size()

	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	parent.visibility_changed.connect(_on_visibility_changed)
	input_handler = UIInputComponent.new()
	add_child(input_handler)

	get_items().map(func(item: MenuElement):
		if item:item.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	)
	set_scroll_size()
	
func get_vbox(parent : Control):
	for chiled in parent.get_children():
		if chiled is MarginContainer:
			for grand_chiled in chiled.get_children():
				if grand_chiled is VBoxContainer:
					return grand_chiled
	
## Getting menu items from handled menu
func get_items() -> Array[MenuElement]:
	var items: Array[MenuElement] = []
	for row in rows:
		for column_ndx in range(column_count):
			# pushing null to preserve grid structure
			# to simplify focus navigation logic

			if column_ndx >= row.get_child_count():
				items.append(null)
				continue

			var column = row.get_child(column_ndx)
			if column is MenuElement:
				
				items.append(column)
			else:
				items.append(null)
	return items

#region Grid navigation logic

func _get_item_at_position(column: int, row: int) -> MenuElement:
	if row < 0:
		if is_cycled:
			row += rows.size()
		else:
			return null
	elif row >= rows.size():
		if is_cycled:
			row = 0
		else:
			return null

	if column < 0:
		if is_cycled:
			column += column_count
		else:
			return null
	elif column >= column_count:
		if is_cycled:
			column = 0
		else:
			return null
	
	var index = _grid_position_to_arr_index(column, row)
	var items = get_items()
	if index < items.size():
		return items[index]
	return null

func _get_item_upper(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column, row - 1)
	if not item and is_cycled:
		return _get_item_upper(column, row - 1)
	return item

func _get_item_lower(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column, row + 1)
	if not item and is_cycled:
		return _get_item_lower(column, row + 1)
	return item

func _get_item_left(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column - 1, row)
	if not item and is_cycled:
		return _get_item_left(column - 1, row)
	return item

func _get_item_right(column: int, row: int) -> MenuElement:
	var item = _get_item_at_position(column + 1, row)
	if not item and is_cycled:
		return _get_item_right(column + 1, row)
	return item

func _arr_indxes_to_grid_position(index: int) -> Vector2i:
	var column = index % column_count
	@warning_ignore("integer_division")
	var row = index / column_count
	return Vector2i(column, row)

func _grid_position_to_arr_index(column: int, row: int) -> int:
	return row * column_count + column

#endregion


# makes sure the ScrollContainer has the right size
func set_scroll_size() -> void:
	var ele_count: int = min(rows.size(),view_hight)
	var hight : float = 4
	hight += 4 * (ele_count - 1)
	var item := _get_item_at_position(0,0)
	if !item:
		return
	hight += item.size.y * ele_count
	var scroll_size := scroll.size
	scroll_size.y = hight
	scroll.set_size(scroll_size)
	scroll.custom_minimum_size = scroll_size

func clear_items() -> void:
	for row in rows:
		for column_ndx in range(column_count):
			var item = _get_item_at_position(column_ndx, rows.find(row))
			if item:
				item.queue_free()

func add_item(item: MenuElement) -> void:
	var items_size = get_items().filter(func(i): return i != null).size()
	var pos = _arr_indxes_to_grid_position(items_size)
	if pos.x >= column_count:
		printerr("No more columns to add items to")
		return
	elif pos.y >= rows.size():
		# printerr("No more rows to add items to")
		var new_row := HBoxContainer.new()
		rows.append(new_row)
		vbox.add_child(new_row)
		
	rows[pos.y].add_child(item)

func create_items(actions: Array[CombatantAction], on_item_pressed: Callable) -> void:
	for action in actions:
		var item = MenuElement.create(action.display_name, self, action)
		item.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		item.pressed.connect(on_item_pressed.bind(action))
		add_item(item)
	set_scroll_size()
	

func scroll_to_row(row: int):
	if row < 0 or row >= rows.size():
		return

	scroll.ensure_control_visible(rows[row])

func _on_gui_focus_changed(item: Control) -> void:
	var items := get_items()
	var index := items.find(item)

	if index == -1:
		return

	var pos := _arr_indxes_to_grid_position(index)

	scroll_to_row(pos.y)


# Implementation for grid layout out of columns as VBoxContainers
# while main container is HBoxContainer
func build_navigation() -> void:
	var items = get_items()
	set_scroll_size()
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

		item.focus_neighbor_left = item.get_path_to(left_item) if left_item else item.get_path()
		item.focus_neighbor_right = item.get_path_to(right_item) if right_item else item.get_path()
		item.focus_neighbor_top = item.get_path_to(top_item) if top_item else item.get_path()
		item.focus_neighbor_bottom = item.get_path_to(bottom_item) if bottom_item else item.get_path()

		if i == 0:
			item.grab_focus()
			#hide_rows(row)
