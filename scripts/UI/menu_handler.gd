extends Node
class_name MenuHandler

## Menu node that should be handled
var parent: Control

var input_handler: InputComponent
var previously_focused_item: MenuElement

func _ready() -> void:
	parent = get_parent() as Control

	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	# parent.visibility_changed.connect(_on_visibility_changed)
	input_handler = InputComponent.new()

	get_items().map(func(item: MenuElement):
		item.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	)

## Getting menu items from handled menu
func get_items() -> Array[MenuElement]:
	var items: Array[MenuElement] = []
	for child in parent.get_children():
		if child is MenuElement:
			items.append(child)
	return items

func _on_visibility_changed() -> void:
	# if parent.visible:
	# 	configure_focus(true)
	pass

func _on_gui_focus_changed(item: Control) -> void:
	if not item: return
	if not item in get_children(): return

	# play sound

func get_focused_item() -> MenuElement:
	var item = get_viewport().gui_get_focus_owner()
	return item if item in get_children() else null

func item_pressed(item: MenuElement) -> void:
	previously_focused_item = item
	item.release_focus()

func clear_items() -> void:
	for item in get_items():
		item.queue_free()

func add_item(item: MenuElement) -> void:
	parent.add_child(item)

func create_items(data: Array, on_item_pressed: Callable) -> void:
	for item_data in data:
		var item = MenuElement.create("text", self, item_data)
		item.setup(item_data)
		item.pressed.connect(on_item_pressed.bind(item_data))
		add_item(item)

## Virtual method.
##
## Configures the focus for child items for navigation
## if reload is true, it will set the focus to the first item.
## Otherwise, it will try to restore focus to the previously focused item.
func configure_focus(_reload: bool = true) -> void:
	pass
