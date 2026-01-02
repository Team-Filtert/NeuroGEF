extends Button
class_name SelectableButton

var contained_object: Object

func init():
	pass

func set_selected(is_select: bool):
	if is_select:
		self.grab_focus()
	else:
		self.release_focus()

func get_selected():
	return self.has_focus()


func select_process():
	print("selected option: " + self.text)

