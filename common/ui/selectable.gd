extends Control
class_name Selectable

static func get_selectable_from_children(node: Node, __initial = true) -> Selectable:
	for N in node.get_children():
		if N is Selectable:
			return N
		if N.get_child_count() > 0:
			var maybe_selected = get_selectable_from_children(N, false)

			if maybe_selected:
				return maybe_selected

	if __initial:
		push_warning("Cannot find selectable child, return null")
	return null

@export var selectable_node: Control

func get_selected() -> bool:
	if selectable_node.has_method("get_selected"):
		return selectable_node.get_selected()
	push_warning("Cannot find get_selected method in selectable_node")
	return false

func set_selected(_is_selected: bool) -> void:
	if selectable_node.has_method("set_selected"):
		selectable_node.set_selected(_is_selected)
		return
	push_warning("Cannot find set_selected method in selectable_node")
	return

func get_is_valid() -> bool:
	if selectable_node.has_method("get_is_valid"):
		return selectable_node.get_is_valid()
	push_warning("Cannot find get_is_valid method in selectable_node")
	return true

func init(validate_func: Callable = Callable()) -> void:
	if selectable_node.has_method("init"):
		selectable_node.init(validate_func)
		return
	push_warning("Cannot find init method in selectable_node")

func select_process():
	if selectable_node.has_method("select_process"):
		return selectable_node.select_process()
	push_warning("Cannot find select_process method in selectable_node")
