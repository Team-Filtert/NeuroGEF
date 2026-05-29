extends Control

const SAVE_SLOT_LIMIT := 3

@onready var slot_button_container: VBoxContainer = $SaveSelectionPanel/MarginContainer/VBoxContainer

func _ready() -> void:
	for i in range(SAVE_SLOT_LIMIT):
		var slot_button := Button.new()

		if not SaveManager.save_file_exists(i + 1):
			slot_button.text = "NEW SAVE"
			slot_button.pressed.connect(_on_create_save_pressed.bind(i + 1))
		else:
			slot_button.text = "SLOT %d" % (i + 1)
			slot_button.pressed.connect(_on_load_save_pressed.bind(i + 1))
			
		slot_button_container.add_child(slot_button)

func _on_create_save_pressed(slot: int) -> void:
	SaveManager.new_game(slot)
	UIManager.clear_ui()
	SceneManager.change_scene_to(load(Game.state.current_scene_path))

func _on_load_save_pressed(slot: int) -> void:
	SaveManager.load_save(slot)
	UIManager.clear_ui()
	SceneManager.change_scene_to(load(Game.state.current_scene_path))

func _on_back_pressed() -> void:
	UIManager.pop_ui()
