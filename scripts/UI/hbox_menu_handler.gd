extends MenuHandler
class_name HBoxMenuHandler

# Implementation for HBoxContainer
func configure_focus(reload: bool = true) -> void:
	if not reload and previously_focused_item:
		previously_focused_item.grab_focus()
		return

	var items = get_items()
	for i in items.size():
		var item: MenuElement = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_top = item.get_path()
		item.focus_neighbor_bottom = item.get_path()

		item.parent_menu = self

		if i == 0:
			item.focus_neighbor_left = item.get_path()
			item.focus_previous = item.get_path()
			item.grab_focus()
		else:
			item.focus_neighbor_left = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbor_right = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_right = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
