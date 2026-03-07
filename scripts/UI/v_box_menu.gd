extends VBoxContainer
class_name VBoxMenu

var input_handler: InputComponent

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	self.visibility_changed.connect(_on_visibility_changed)
	input_handler = InputComponent.new()

	get_items().map(func(item: MenuElement):
		item.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	)

func get_items() -> Array[MenuElement]:
	var items: Array[MenuElement] = []
	for child in get_children():
		if child is MenuElement:
			items.append(child)
	return items

func _on_visibility_changed() -> void:
	if visible:
		configure_focus()

func _on_gui_focus_changed(item: Control) -> void:
	if not item: return
	if not item in get_children(): return

	# play sound

func get_focused_item() -> MenuElement:
	var item = get_viewport().gui_get_focus_owner()
	return item if item in get_children() else null

func configure_focus() -> void:
	var items = get_items()
	for i in items.size():
		var item: MenuElement = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		item.parent_menu = self

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
			item.grab_focus()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

func item_pressed(item: MenuElement) -> void:
	item.release_focus()
