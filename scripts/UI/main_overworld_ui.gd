extends Control


var is_expanded = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if CombatManager.is_in_combat:
		hide()
	elif is_expanded:
		show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CombatManager.is_in_combat:
		hide()
	elif is_expanded:
		show()
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			if is_expanded:
				collapse_menu()
			else:
				expand_menu()
		else:
			collapse_menu()

func expand_menu():
	is_expanded = true
	show()

func collapse_menu():
	is_expanded = false
	hide()