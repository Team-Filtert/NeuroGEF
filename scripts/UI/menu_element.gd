extends Button
class_name MenuElement

var parent_menu: Control

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# play sound
	if parent_menu and parent_menu.has_method("item_pressed"):
		parent_menu.item_pressed(self)

