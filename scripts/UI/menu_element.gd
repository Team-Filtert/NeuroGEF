extends Button
class_name MenuElement

static func create(display_text: String, menu: MenuHandler, store_data: Variant) -> MenuElement:
	var element = MenuElement.new()
	element.text = display_text
	element.parent_menu = menu
	element.data = store_data
	return element

var parent_menu: MenuHandler
var data: Variant

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# play sound
	if parent_menu and parent_menu.has_method("item_pressed"):
		parent_menu.item_pressed(self)
