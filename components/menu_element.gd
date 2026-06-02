extends Button
class_name MenuElement
@export var text_key: String

static func create(key: String, menu: MenuHandler, store_data: Variant) -> MenuElement:
	var element = MenuElement.new()
	element.text_key = key
	element.parent_menu = menu
	element.data = store_data
	return element

var parent_menu: MenuHandler
var data: Variant

func _ready() -> void:
	self.pressed.connect(_on_pressed)
	self.text = tr(text_key)

func update_text():
	self.text = tr(text_key)

func _on_pressed() -> void:
	# play sound
	if parent_menu and parent_menu.has_method("item_pressed"):
		parent_menu.item_pressed(self)
