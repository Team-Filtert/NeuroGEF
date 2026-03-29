extends VBoxMenuHandler


@export var remove_save_button: Button

var in_remove_state = false

func _ready():
	_menu_handler_init()

	configure_save_slots()
	
	remove_save_button.pressed.connect(remove_save_state_handle)

	parent.visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	in_remove_state = false
	for save_slot in get_items():
		if save_slot.pressed.is_connected(start_game_in_slot):
			save_slot.disabled = false

func clear_signal_connections():
	var slot_containers := get_items()
	for slot_container in slot_containers:
		if slot_container.pressed.is_connected(load_game):
			slot_container.pressed.disconnect(load_game)
		if slot_container.pressed.is_connected(start_game_in_slot):
			slot_container.pressed.disconnect(start_game_in_slot)

func configure_save_slots():
	clear_signal_connections()

	var slot_containers := get_items()
	var save_slot_num = 1
	for slot_container in slot_containers:
		slot_container.disabled = false

		if SaveManager.check_save_file_exists(save_slot_num):
			slot_container.text = "SLOT " + str(save_slot_num)
			slot_container.pressed.connect(load_game.bind(save_slot_num))
		else:
			slot_container.text = "EMPTY SLOT " + str(save_slot_num)
			slot_container.pressed.connect(start_game_in_slot.bind(save_slot_num))
		
		save_slot_num += 1

func post_focus_configure():
	var last_item: MenuElement = get_items().pop_back()
	last_item.focus_neighbor_bottom = remove_save_button.get_path()
	remove_save_button.focus_neighbor_top = last_item.get_path()

func remove_save_state_handle():
	in_remove_state = not in_remove_state

	for save_slot in get_items():
		if save_slot.pressed.is_connected(start_game_in_slot):
			save_slot.disabled = in_remove_state
	
	configure_focus()

func remove_save(save_slot: int):
	SaveManager.remove_save_file(save_slot)
	remove_save_state_handle()
	configure_save_slots()

func load_game(save_slot: int):
	if in_remove_state:
		remove_save(save_slot)
		return

	SaveManager.load(save_slot)
	SceneManager.current_scene_init()
	parent.visible = false

func start_game_in_slot(save_slot: int):
	if in_remove_state:
		return

	parent.visible = false

	var starting_scene_filepath = SceneManager.str_to_scene_res_path(
		SceneManager.starting_scene
	)

	GameManager.load_state(starting_scene_filepath, {
		"pos_x": 0,
		"pos_y": 0,
	}, ["res://scenes/characters/player.tscn"], [], [], [], [], [])

	SaveManager.save(save_slot)

