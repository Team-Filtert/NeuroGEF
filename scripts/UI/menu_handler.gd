extends Node
class_name MenuHandler

## Menu node that should be handled
var parent: Control

var input_handler: UIInputComponent
var previously_focused_item: MenuElement

var callable_unfocus_event: Callable

func _ready() -> void:
	parent = get_parent() as Control

	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	# parent.visibility_changed.connect(_on_visibility_changed)
	input_handler = UIInputComponent.new()
	add_child(input_handler)

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

func item_pressed(item: MenuElement) -> void:
	previously_focused_item = item
	item.release_focus()
	if input_handler.got_cancel_input.is_connected(_unfocus_menu):
		input_handler.got_cancel_input.disconnect(_unfocus_menu)

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

func _unfocus_menu():
	if callable_unfocus_event.is_valid():
		callable_unfocus_event.call()


## Configures the focus for child items for navigation
## if reload is true, it will set the focus to the first item.
## Otherwise, it will try to restore focus to the previously focused item.
func configure_focus(reload: bool = true) -> void:
	if not input_handler.got_cancel_input.is_connected(_unfocus_menu):
		input_handler.got_cancel_input.connect(_unfocus_menu, ConnectFlags.CONNECT_ONE_SHOT)

	if not reload and previously_focused_item:
		previously_focused_item.grab_focus()
		return
	
	build_navigation()

# virtual_method
func build_navigation() -> void:
	pass
